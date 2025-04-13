# frozen_string_literal: true

module Sai
  class EncodingSpecification
    include ManagedAttributes

    computed_attribute :adapted_white_point,
                       depends_on: %i[chromatic_adaptation_transform color_space illuminant observer] do
      if chromatic_adaptation_transform != color_space.native_chromatic_adaptation_transform ||
         illuminant != color_space.native_illuminant

        chromatic_adaptation_transform.adapt(
          color_space.native_illuminant.white_point,
          source_white: color_space.native_illuminant.white_point,
          target_white: illuminant.white_point,
        )
      else
        illuminant.white_point
      end
    end

    attribute :chromatic_adaptation_transform, ChromaticAdaptationTransform,
              default: -> { color_space.chromatic_adaptation_transform },
              depends_on: %i[color_space],
              required: true
    alias_attribute :cat, :chromatic_adaptation_transform

    attribute :color_space, Space, default: -> { Sai.config.default_color_space }, required: true

    computed_attribute :description,
                       depends_on:
                         %i[chromatic_adaptation_transform color_space illuminant observer viewing_condition] do
      "#{color_space.name} color space with #{illuminant.name} illuminant being observed by #{observer.name} " \
        "under #{viewing_condition.name} viewing conditions using the #{chromatic_adaptation_transform.name} " \
        'chromatic adaptation method'
    end

    attribute :illuminant, Illuminant,
              default: -> { color_space.illuminant },
              depends_on: %i[color_space],
              required: true

    attribute :observer, Observer,
              default: -> { color_space.observer },
              depends_on: %i[color_space],
              required: true

    attribute :viewing_condition, ViewingCondition, default: -> { Sai.config.default_viewing_condition }, required: true

    def initialize(**attributes)
      super
      freeze
    end

    def chromaticity_in_gamut?(chromaticity)
      unless chromaticity.is_a?(Chromaticity)
        raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got: #{chromaticity.inspect}"
      end

      color_space.contains_chromaticity?(chromaticity)
    end

    def chromaticity_to_xyz(chromaticity)
      x, y, z = Sai.cache.fetch(EncodingSpecification, :chromaticity_to_xyz, *chromaticity.channel_cache_key, hash) do
        unless chromaticity.is_a?(Chromaticity)
          raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got: #{chromaticity.inspect}"
        end

        if adapted_white_point == color_space.native_illuminant.white_point
          chromaticity.to_xyz.to_n_a
        else
          chromatic_adaptation_transform.adapt(
            chromaticity.to_xyz,
            source_white: color_space.native_illuminant.white_point,
            target_white: adapted_white_point,
          ).to_n_a
        end
      end

      Model::XYZ.new(x, y, z, encoding_specification: self)
    end

    def in_gamut?(color)
      raise TypeError, "`color` is invalid. Expected `Sai::Model`, got: #{color.inspect}" unless color.is_a?(Model)

      Sai.cache.fetch(EncodingSpecification, :in_gamut?, color.symbol, *color.channel_cache_key, hash) do
        xyz = color.to_xyz(encoding_specification: self)

        xyz_vector = xyz_to_rgb_matrix.class.column_vector(xyz)
        rgb_vector = xyz_to_rgb_matrix * xyz_vector
        linear_rgb_values = rgb_vector.to_a.flatten

        rgb_values = linear_rgb_values.map { |v| color_space.gamma.from_linear(v) }

        rgb_values.all? { |v| v.between?(0.0, 1.0) }
      end
    end

    def map_to_gamut(color, strategy: Sai.config.default_gamut_mapping_strategy)
      raise TypeError, "`color` is invalid. Expected `Sai::Model`, got: #{color.inspect}" unless color.is_a?(Model)

      x, y, z = Sai.cache.fetch(EncodingSpecification, :map_to_gamut, color.symbol, *color.channel_cache_key, hash) do
        xyz = color.to_xyz(encoding_specification: self)

        if in_gamut?(color)
          xyz.to_n_a
        else
          case strategy
          when Sai::Enum::Gamut::MappingStrategy::COMPRESS
            lab = xyz.to_lab(encoding_specification: self)
            l, a, b = lab.to_n_a

            original_chroma = Math.sqrt((a * a) + (b * b))

            chroma_scale = 1.0
            min_scale = 0.0
            max_scale = 1.0

            8.times do
              test_chroma = original_chroma * chroma_scale

              if original_chroma.positive?
                chroma_ratio = test_chroma / original_chroma
                test_a = a * chroma_ratio
                test_b = b * chroma_ratio
              else
                test_a = 0
                test_b = 0
              end

              test_lab = Model::Lab.new(l, test_a, test_b, encoding_specification: self)

              in_gamut = in_gamut?(test_lab)

              if in_gamut
                min_scale = chroma_scale
                chroma_scale = (chroma_scale + max_scale) / 2
              else
                max_scale = chroma_scale
                chroma_scale = (chroma_scale + min_scale) / 2
              end
            end

            final_chroma = original_chroma * min_scale

            if original_chroma.positive?
              final_ratio = final_chroma / original_chroma
              final_a = a * final_ratio
              final_b = b * final_ratio
            else
              final_a = 0
              final_b = 0
            end

            final_lab = Model::Lab.new(l, final_a, final_b, encoding_specification: self)
            final_xyz = final_lab.to_xyz(encoding_specification: self)

            unless in_gamut?(final_lab)
              final_xyz = map_to_gamut(
                Model::XYZ.new(*final_xyz.to_n_a, encoding_specification: self),
                strategy: Sai::Enum::Gamut::MappingStrategy::CLIP,
              )
            end

            final_xyz.to_n_a
          when Sai::Enum::Gamut::MappingStrategy::SCALE, Sai::Enum::Gamut::MappingStrategy::CLIP
            xyz_vector = xyz_to_rgb_matrix.class.column_vector(xyz)
            rgb_vector = xyz_to_rgb_matrix * xyz_vector
            linear_rgb_values = rgb_vector.to_a.flatten

            rgb_values = linear_rgb_values.map { |v| color_space.gamma.from_linear(v) }

            linear_rgb = case strategy
                         when Sai::Enum::Gamut::MappingStrategy::SCALE
                           max_value = rgb_values.map(&:abs).max
                           scale_factor = max_value > 1.0 ? 1.0 / max_value : 1.0 # rubocop:disable Metrics/BlockNesting
                           rgb_values.map { |v| v * scale_factor }
                         when Sai::Enum::Gamut::MappingStrategy::CLIP
                           rgb_values.map { |v| v.clamp(0.0, 1.0) }
                         end

            rgb_vector = rgb_to_xyz_matrix.class.column_vector(linear_rgb.map { |v| color_space.gamma.to_linear(v) })
            xyz_vector = rgb_to_xyz_matrix * rgb_vector
            xyz_vector.to_a.flatten
          else
            raise ArgumentError, '`:strategy` is invalid. Expected one of ' \
                                 "#{Sai::Enum::Gamut::MappingStrategy.resolve_all.join(', ')}, got: #{strategy.inspect}"
          end
        end
      end

      color.coerce(Model::XYZ.new(x, y, z, encoding_specification: self), encoding_specification: self)
    end

    def rgb_to_xyz_matrix
      rows = Sai.cache.fetch(EncodingSpecification, :rgb_to_xyz_matrix, hash) do
        r_xyz, g_xyz, b_xyz = color_space.primaries.map { |primary| chromaticity_to_xyz(primary) }

        primary_matrix = Matrix[
          [r_xyz.x, g_xyz.x, b_xyz.x],
          [r_xyz.y, g_xyz.y, b_xyz.y],
          [r_xyz.z, g_xyz.z, b_xyz.z],
        ]

        white_point_vector = Matrix.column_vector(illuminant.white_point)
        scaling_vector = primary_matrix.inverse * white_point_vector
        sr, sg, sb = scaling_vector.to_a.flatten

        scaling_matrix = Matrix[
          [sr, 0, 0],
          [0, sg, 0],
          [0, 0, sb],
        ]

        (primary_matrix * scaling_matrix).to_a
      end

      Matrix[*rows]
    end

    def xyz_to_rgb_matrix
      rows = Sai.cache.fetch(EncodingSpecification, :xyz_to_rgb_matrix, hash) { rgb_to_xyz_matrix.inverse.to_a }
      Matrix[*rows]
    end
  end
end
