# frozen_string_literal: true

module Sai
  module Space
    module Encoded
      class RGB < Base
        autoload :Category,      'sai/space/encoded/rgb/category'
        autoload :Derivative,    'sai/space/encoded/rgb/derivative'
        autoload :GammaStrategy, 'sai/space/encoded/rgb/gamma_strategy'
        autoload :XYZMatrix,     'sai/space/encoded/rgb/xyz_matrix'

        extend Sai::Core::DefferedConstant

        HEX_PATTERN = /^#?([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})$/

        abstract_space
        implements Model::RGB

        class << self
          attr_reader :blue_primary_chromaticity
          alias blue_primary blue_primary_chromaticity

          attr_reader :category

          attr_reader :gamma_exponent
          attr_reader :gamma_strategy

          attr_reader :green_primary_chromaticity
          alias green_primary green_primary_chromaticity

          attr_reader :opto_electronic_transfer_function_linear_cutoff
          alias oetf_linear_cutoff opto_electronic_transfer_function_linear_cutoff

          attr_reader :opto_electronic_transfer_function_linear_slope
          alias oetf_linear_slope opto_electronic_transfer_function_linear_slope

          attr_reader :opto_electronic_transfer_function_offset
          alias oetf_offset opto_electronic_transfer_function_offset

          attr_reader :opto_electronic_transfer_function_power_scale
          alias oetf_power_scale opto_electronic_transfer_function_power_scale

          attr_reader :opto_electronic_transfer_function_threshold
          alias oetf_threshold opto_electronic_transfer_function_threshold

          attr_reader :red_primary_chromaticity
          alias red_primary red_primary_chromaticity

          attr_reader :to_xyz_matrix

          def from_linear(value)
            case gamma_strategy
            when GammaStrategy::LINEAR
              value**(1.0 / gamma_exponent)
            when GammaStrategy::TRANSFER_FUNCTION
              if value <= oetf_linear_cutoff
                value * oetf_linear_slope
              else
                (oetf_power_scale * (value**(1.0 / gamma_exponent))) - oetf_offset
              end
            end
          end

          def from_xyz_matrix
            concurrent_instance_variable_fetch(:@from_xyz_matrix, to_xyz_matrix.inverse)
          end

          def primaries
            [
              red_primary_chromaticity,
              green_primary_chromaticity,
              blue_primary_chromaticity,
            ].freeze
          end

          def to_linear(value)
            case gamma_strategy
            when GammaStrategy::LINEAR
              value**gamma_exponent
            when GammaStrategy::TRANSFER_FUNCTION
              if value <= oetf_threshold
                value / oetf_linear_slope
              else
                ((value + oetf_offset) / oetf_power_scale)**gamma_exponent
              end
            end
          end

          private

          def categorized_as(category)
            unless Category::ALL.include?(category)
              raise ArgumentError, "`category` is invalid. Expected one of #{Category::ALL.join(', ')}, " \
                                   "got: #{category.inspect}"
            end

            mutex.synchronize { @category = category }
          end

          def load_space(path, **options)
            data = Sai.data_store.load(path, **options).transform_keys(&:to_sym)

            illuminant = Illuminant.const_get(data[:native_illuminant])

            space = Class.new(self)

            space.send(:identified_as, data[:identifier])
            space.send(:categorized_as, data[:category])
            space.send(:with_native, illuminant: illuminant)
            space.send(:with_red_primary_chromaticity, *data[:red_primary_chromaticity])
            space.send(:with_green_primary_chromaticity, *data[:green_primary_chromaticity])
            space.send(:with_blue_primary_chromaticity, *data[:blue_primary_chromaticity])
            space.send(:with_gamma_settings, **data[:gamma_settings])

            space.send(
              :concurrent_instance_variable_fetch,
              :@to_xyz_matrix,
              XYZMatrix.generate(space.native_context.white_point, space.primaries),
            )

            space
          end

          def with_blue_primary_chromaticity(x, y)
            mutex.synchronize { @blue_primary_chromaticity = Chromaticity.xy(x, y) }
          end

          def with_gamma_settings(**settings)
            gamma_strategy     = settings.fetch(:strategy, @gamma_strategy)
            gamma_exponent     = settings.fetch(:exponent, @gamma_exponent)
            oetf_linear_cutoff = settings.fetch(:linear_cutoff, @oetf_linear_cutoff)
            oetf_linear_slope  = settings.fetch(:linear_slope, @oetf_linear_slope)
            oetf_offset        = settings.fetch(:offset, @oetf_offset)
            oetf_power_scale   = settings.fetch(:power_scale, @oetf_power_scale)
            oetf_threshold     = settings.fetch(:threshold, @oetf_threshold)

            unless GammaStrategy::ALL.include?(gamma_strategy)
              raise ArgumentError, '`:strategy` is invalid. Expected one of ' \
                                   "#{GammaStrategy::ALL.join(', ')}, got: #{gamma_strategy.inspect}"
            end

            if gamma_exponent.nil?
              raise ArgumentError, "`:exponent` is invalid. Expected `Numeric`, got: #{gamma_exponent.inspect}"
            end

            if gamma_strategy == GammaStrategy::TRANSFER_FUNCTION
              { oetf_linear_cutoff:, oetf_linear_slope:, oetf_offset:, oetf_power_scale:, oetf_threshold: }
                .each_pair do |key, value|
                next unless value.nil?

                raise ArgumentError, "`:#{key}` is invalid. Expected `Numeric`, got: #{value.inspect}"
              end
            end

            mutex.synchronize do
              @gamma_strategy     = gamma_strategy
              @gamma_exponent     = gamma_exponent

              @opto_electronic_transfer_function_linear_cutoff = oetf_linear_cutoff
              @opto_electronic_transfer_function_linear_slope  = oetf_linear_slope
              @opto_electronic_transfer_function_offset        = oetf_offset
              @opto_electronic_transfer_function_power_scale   = oetf_power_scale
              @opto_electronic_transfer_function_threshold     = oetf_threshold
            end
          end

          def with_green_primary_chromaticity(x, y)
            mutex.synchronize { @green_primary_chromaticity = Chromaticity.xy(x, y) }
          end

          def with_red_primary_chromaticity(x, y)
            mutex.synchronize { @red_primary_chromaticity = Chromaticity.xy(x, y) }
          end
        end

        deffered_constant(:Aces) do
          load_space('rgb_space/aces.yml', symbolize_names: true)
        end

        deffered_constant(:AcesCG) do
          load_space('rgb_space/aces_cg.yml', symbolize_names: true)
        end

        deffered_constant(:Adobe1998) do
          load_space('rgb_space/adobe_1998.yml', symbolize_names: true)
        end

        deffered_constant(:AlexaWideGamut) do
          load_space('rgb_space/alexa_wide_gamut.yml', symbolize_names: true)
        end

        deffered_constant(:Apple) do
          load_space('rgb_space/apple.yml', symbolize_names: true)
        end

        deffered_constant(:Best) do
          load_space('rgb_space/best.yml', symbolize_names: true)
        end

        deffered_constant(:Beta) do
          load_space('rgb_space/beta.yml', symbolize_names: true)
        end

        deffered_constant(:Bruce) do
          load_space('rgb_space/bruce.yml', symbolize_names: true)
        end

        deffered_constant(:CIE) do
          load_space('rgb_space/cie.yml', symbolize_names: true)
        end

        deffered_constant(:ColorMatch) do
          load_space('rgb_space/color_match.yml', symbolize_names: true)
        end

        deffered_constant(:DCIP3) do
          load_space('rgb_space/dci_p3.yml', symbolize_names: true)
        end

        deffered_constant(:DisplayP3) do
          load_space('rgb_space/display_p3.yml', symbolize_names: true)
        end

        deffered_constant(:Don4) do
          load_space('rgb_space/don4.yml', symbolize_names: true)
        end

        deffered_constant(:ECI) do
          load_space('rgb_space/eci.yml', symbolize_names: true)
        end

        deffered_constant(:EktaSpacePS5) do
          load_space('rgb_space/ekta_space_ps5.yml', symbolize_names: true)
        end

        deffered_constant(:NTSC) do
          load_space('rgb_space/ntsc.yml', symbolize_names: true)
        end

        deffered_constant(:PALSecam) do
          load_space('rgb_space/pal_secam.yml', symbolize_names: true)
        end

        deffered_constant(:ProPhoto) do
          load_space('rgb_space/pro_photo.yml', symbolize_names: true)
        end

        deffered_constant(:Rec2020) do
          load_space('rgb_space/rec2020.yml', symbolize_names: true)
        end

        deffered_constant(:Rec709) do
          load_space('rgb_space/rec709.yml', symbolize_names: true)
        end

        deffered_constant(:RIMM) do
          load_space('rgb_space/rimm_rgb.yml', symbolize_names: true)
        end

        deffered_constant(:SGamut3) do
          load_space('rgb_space/s_gamut3.yml', symbolize_names: true)
        end

        deffered_constant(:SGamut3Cine) do
          load_space('rgb_space/s_gamut3_cine.yml', symbolize_names: true)
        end

        deffered_constant(:SMPTEC) do
          load_space('rgb_space/smpte_c.yml', symbolize_names: true)
        end

        deffered_constant(:Standard) do
          load_space('rgb_space/standard.yml', symbolize_names: true)
        end

        deffered_constant(:WideGamut) do
          load_space('rgb_space/wide_gamut.yml', symbolize_names: true)
        end

        def to_cmy(**options)
          rgb_space = options.fetch(:rgb_space, self.class)

          convert_to(CMY, rgb_space:, map_to_gamut: true, **options) do
            nr, ng, nb = to_a
            [
              1.0 - nr,
              1.0 - ng,
              1.0 - nb,
            ]
          end
        end

        def to_cmyk(**options)
          rgb_space = options.fetch(:rgb_space, self.class)

          convert_to(CMYK, rgb_space:, map_to_gamut: true, **options) do
            nr, ng, nb = normalized = to_a
            k = 1.0 - normalized.max

            if k >= 1.0
              [0.0, 0.0, 0.0, 1.0]
            else
              [
                (1.0 - nr - k) / (1.0 - k),
                (1.0 - ng - k) / (1.0 - k),
                (1.0 - nb - k) / (1.0 - k),
                k,
              ]
            end
          end
        end

        def to_css
          srgb = to_srgb
          opacity_string = opacity < PERCENTAGE_RANGE.end ? " / #{opacity.round(2)}" : ''
          "rgb(#{srgb.red} #{srgb.green} #{srgb.blue}#{opacity_string})"
        end

        def to_hsb(**options)
          rgb_space = options.fetch(:rgb_space, self.class)

          convert_to(HSB, rgb_space:, map_to_gamut: true, **options) { to_hsv(rgb_space:, **options).to_a }
        end

        def to_hsl(**options)
          rgb_space = options.fetch(:rgb_space, self.class)

          convert_to(HSL, rgb_space:, map_to_gamut: true, **options) do
            nr, ng, nb = normalized = to_a

            min = normalized.min
            max = normalized.max

            delta = (max - min).to_f
            l = (max + min) / 2.0

            if delta == 0.0
              h = 0
              s = 0
            else
              s = if l <= 0.5
                    delta / (max + min)
                  else
                    delta / (2.0 - max - min)
                  end

              h = if nr == max
                    ((ng - nb) / delta) % 6.0
                  elsif ng == max
                    ((nb - nr) / delta) + (6.0 / 3.0)
                  elsif nb == max
                    ((nr - ng) / delta) + ((6.0 / 3.0) * 2.0)
                  end

              h /= 6.0
            end

            h = (h + 1) % 1 if h.negative?

            [h, s, l]
          end
        end

        def to_hsv(**options)
          rgb_space = options.fetch(:rgb_space, self.class)

          convert_to(HSV, rgb_space:, map_to_gamut: true, **options) do
            nr, ng, nb = normalized = to_a

            c_max = normalized.max
            c_min = normalized.min
            delta = c_max - c_min

            h = 0.0
            if delta != 0.0
              h = case c_max
                  when nr
                    ((ng - nb) / delta) % 6.0
                  when ng
                    ((nb - nr) / delta) + (6.0 / 3.0)
                  when nb
                    ((nr - ng) / delta) + ((6.0 / 3.0) * 2.0)
                  end

              h /= 6.0
            end

            s = c_max == 0.0 ? 0.0 : delta / c_max
            v = c_max

            [h, s, v]
          end
        end

        def to_oklab(**options)
          convert_to(Perceptual::Oklab, **options) do
            linear_srgb = to_srgb.to_a.map { |component| Standard.to_linear(component) }

            rgb_matrix = Perceptual::Oklab::LINEAR_RGB_MATRIX
            lms_linear = (rgb_matrix * rgb_matrix.column_vector(linear_srgb)).to_a.flatten

            lms_nonlinear = lms_linear.map { |component| component**(1.0 / 3.0) }

            lms_matrix = Perceptual::Oklab::LINEAR_LMS_MATRIX
            (lms_matrix * lms_matrix.column_vector(lms_nonlinear)).to_a.flatten
          end
        end

        def to_rgb(**options)
          rgb_space = options.fetch(:rgb_space, self.class)
          return self if rgb_space == self.class

          convert_to(rgb_space, map_to_gamut: true, **options) do |context|
            xyz = to_xyz(**context.to_h)
            matrix = rgb_space.from_xyz_matrix
            linear = (matrix * matrix.column_vector(xyz)).to_a.flatten
            linear.map { |component| rgb_space.from_linear(component) }
          end
        end

        def to_xyz(**options)
          convert_to(Physiological::XYZ, **options) do
            linear = to_a.map { |component| self.class.to_linear(component) }
            (to_xyz_matrix * to_xyz_matrix.column_vector(linear)).to_a.flatten
          end
        end

        def to_xyz_matrix
          concurrent_instance_variable_fetch(
            :@to_xyz_matrix,
            XYZMatrix.generate(local_context.white_point, self.class.primaries),
          )
        end
      end
    end
  end
end
