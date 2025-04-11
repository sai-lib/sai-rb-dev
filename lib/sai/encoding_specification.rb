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

      Model::XYZ.new(x, y, z)
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
