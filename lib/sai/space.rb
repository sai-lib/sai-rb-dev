# frozen_string_literal: true

module Sai
  class Space
    autoload :Gamma, 'sai/space/gamma'

    include ManagedAttributes

    attribute :blue_primary_chromaticity, Chromaticity,
              coerce: ->(v) { v.is_a?(Chromaticity) ? v : Chromaticity.new(*v) },
              required: true
    alias_attribute :blue_primary, :blue_primary_chromaticity

    attribute :category, Symbol, required: true

    attribute :chromatic_adaptation_transform, ChromaticAdaptationTransform,
              default: -> { native_chromatic_adaptation_transform },
              depends_on: %i[native_chromatic_adaptation_transform],
              required: true
    alias_attribute :cat, :chromatic_adaptation_transform

    computed_attribute :estimated_gamut_volume_percentage, depends_on: %i[gamut_area] do
      visible_colors_area = 0.1950

      percentage = (gamut_area / visible_colors_area) * PERCENTAGE_RANGE.end
      [percentage, PERCENTAGE_RANGE.end].min
    end

    attribute :gamma, Gamma, coerce: ->(v) { v.is_a?(Gamma) ? v : Gamma.new(**v) }, required: true

    computed_attribute :gamut_area,
                       depends_on: %i[blue_primary_chromaticity green_primary_chromaticity red_primary_chromaticity] do
      xr, yr, xg, yg, xb, yb = primaries.map(&:to_a).flatten

      0.5 * ((xr * (yg - yb)) + (xg * (yb - yr)) + (xb * (yr - yg))).abs
    end

    attribute :green_primary_chromaticity, Chromaticity,
              coerce: ->(v) { v.is_a?(Chromaticity) ? v : Chromaticity.new(*v) },
              required: true
    alias_attribute :green_primary, :green_primary_chromaticity

    attribute :illuminant, Illuminant,
              default: -> { native_illuminant },
              depends_on: %i[native_illuminant],
              required: true

    attribute :modifications, Hash, default: EMPTY_HASH, required: true

    attribute :name, String, required: true

    attribute :native_chromatic_adaptation_transform, ChromaticAdaptationTransform, required: true
    alias_attribute :native_cat, :native_chromatic_adaptation_transform

    attribute :native_illuminant, Illuminant, required: true

    attribute :native_observer, Observer, required: true

    attribute :observer, Observer, default: -> { native_observer }, depends_on: %i[native_observer], required: true

    attribute :red_primary_chromaticity, Chromaticity,
              coerce: ->(v) { v.is_a?(Chromaticity) ? v : Chromaticity.new(*v) },
              required: true
    alias_attribute :red_primary, :red_primary_chromaticity

    validates :category, "must be one of #{Enum::ColorSpace::Category.resolve_all.join(', ')}" do |category|
      Enum::ColorSpace::Category.resolve_all.include?(category)
    end

    def self.load(path, **options)
      data = Sai.data_store.load(path, **options).transform_keys(&:to_sym)

      native_chromatic_adaptation_transform_id = data.delete(:native_chromatic_adaptation_transform_id)
      native_illuminant_id = data.delete(:native_illuminant_id)
      native_observer_id = data.delete(:native_observer_id)

      native_chromatic_adaptation_transform =
        Enum::ChromaticAdaptationTransform.resolve(native_chromatic_adaptation_transform_id)
      native_illuminant = Enum::Illuminant.resolve(native_illuminant_id)
      native_observer = Enum::Observer.resolve(native_observer_id)

      new(
        native_chromatic_adaptation_transform: native_chromatic_adaptation_transform,
        native_illuminant: native_illuminant,
        native_observer: native_observer,
        **data,
      )
    end

    def initialize(**attributes)
      super

      @name = modified_name
      freeze
    end

    def contains_chromaticity?(chromaticity)
      unless chromaticity.is_a?(Chromaticity)
        raise TypeError, "`chromaticity` is invalid. Expected `Sai::Chromaticity`, got: #{chromaticity.inspect}"
      end

      Sai.cache.fetch(Space, :contains_chromaticity?, hash, *chromaticity.channel_cache_key) do
        x, y = chromaticity.to_n_a

        xr, yr, xg, yg, xb, yb = primaries.map(&:to_a).flatten

        d1 = (((yg - yb) * (x - xb)) + ((xb - xg) * (y - yb))) /
             (((yg - yb) * (xr - xb)) + ((xb - xg) * (yr - yb)))

        d2 = (((yb - yr) * (x - xb)) + ((xr - xb) * (y - yb))) /
             (((yg - yb) * (xr - xb)) + ((xb - xg) * (yr - yb)))

        d3 = 1 - d1 - d2

        d1 >= 0 && d2 >= 0 && d3 >= 0
      end
    end

    def gamut_ratio_to(other)
      other = Enum.resolve(other)
      raise TypeError, "`other` is invalid. Expected `Sai::Space`, got: #{other.inspect}" unless other.is_a?(Space)

      gamut_area / other.gamut_area
    end

    def primaries
      [red_primary_chromaticity, green_primary_chromaticity, blue_primary_chromaticity]
    end

    def wide_gamut?(other)
      other = Enum.resolve(other)
      raise TypeError, "`other` is invalid. Expected `Sai::Space`, got: #{other.inspect}" unless other.is_a?(Space)

      gamut_ratio_to(other) > 1.2
    end

    private

    def modified_name
      return name if modifications.empty?

      modified_name = name.gsub('Modified', '').gsub(/\((.*?)\)/, '').strip
      "#{modified_name} Modified (#{modifications.map { |k, v| "#{k}: #{v}" }.join(', ')})"
    end
  end
end
