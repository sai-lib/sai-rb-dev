# frozen_string_literal: true

module Sai
  module Space
    module Core
      module Gamut
        class << self
          private

          def included(base)
            super

            base.include InstanceMethods
          end
        end

        module RGBSpaceResolver
          class << self
            def call(caller, rgb_space_argument = nil)
              rgb_space_argument ||= if caller.class < Encoded::RGB
                                       caller.class
                                     elsif caller.respond_to?(:rgb_space)
                                       caller.rgb_space
                                     else
                                       Sai.config.default_rgb_space
                                     end
              unless rgb_space_argument.is_a?(Class) && rgb_space_argument < Encoded::RGB
                raise TypeError, '`rgb_space` is invalid. Expected a subclass of `Sai::Space::Encoded::RGB, ' \
                                 "got: #{rgb_space_argument.inspect}"
              end

              rgb_space_argument
            end
          end
        end

        module InstanceMethods
          def clip_to_gamut(rgb_space = nil)
            rgb_space = RGBSpaceResolver.call(self, rgb_space)
            return self if in_gamut?(rgb_space)

            rgb = to_rgb(rgb_space:).to_a.map { |component| component.clamp(FRACTION_RANGE) }
            coerce(rgb_space.from_intermediate(*rgb))
          end

          def compress_to_gamut(rgb_space = nil)
            rgb_space = RGBSpaceResolver.call(self, rgb_space)
            return self if in_gamut?(rgb_space)

            lab = Sai.cache.fetch(self.class, :compress_to_gamut, identity, rgb_space) do
              l, a, b         = to_lab_d50.to_a
              original_chroma = Math.sqrt((a * a) + (b * b))

              if original_chroma.zero?
                [l, a, b]
              else
                min_scale = 0.0
                max_scale = 1.0
                iterations = 10

                iterations.times do
                  test_scale  = (min_scale + max_scale) / 2.0
                  test_chroma = original_chroma * test_scale

                  if original_chroma.positive?
                    chroma_ratio = test_chroma / original_chroma
                    test_a = a * chroma_ratio
                    test_b = b * chroma_ratio
                  else
                    test_a = 0
                    test_b = 0
                  end

                  test_lab = Perceptual::Lab::D50.from_intermediate(l, test_a, test_b)

                  if test_lab.in_gamut?(rgb_space)
                    min_scale = test_scale
                  else
                    max_scale = test_scale
                  end
                end

                final_chroma = original_chroma * min_scale
                final_ratio  = final_chroma / original_chroma
                final_a      = a * final_ratio
                final_b      = b * final_ratio

                Perceptual::Lab::D50.from_intermediate(l, final_a, final_b).to_a
              end
            end

            rgb_result = Perceptual::Lab::D50.from_intermediate(*lab).to_rgb(rgb_space:)
            rgb_result.in_gamut?(rgb_space) ? coerce(rgb_result) : coerce(rgb_result.clip_to_gamut(rgb_space))
          end

          def in_gamut?(rgb_space = nil)
            rgb_space = RGBSpaceResolver.call(self, rgb_space)

            is_a?(rgb_space) ? to_a.all?(FRACTION_RANGE) : to_rgb(rgb_space:).to_a.all?(FRACTION_RANGE)
          end

          def map_to_gamut(**options)
            strategy = options.fetch(:strategy, Sai.config.default_gamut_mapping_strategy)
            unless Space::Gamut::Mapping::ALL.include?(strategy)
              raise ArgumentError, '`:strategy` is invalid. Expected one of: ' \
                                   "#{Space::Gamut::Mapping::ALL.join(', ')}, got: #{strategy.inspect}"
            end

            rgb_space = RGBSpaceResolver.call(self, options[:rgb_space])

            case strategy
            when Space::Gamut::Mapping::PERCEPTUAL then perceptually_map_to_gamut(rgb_space)
            when Space::Gamut::Mapping::COMPRESS   then compress_to_gamut(rgb_space)
            when Space::Gamut::Mapping::CLIP       then clip_to_gamut(rgb_space)
            when Space::Gamut::Mapping::SCALE      then scale_to_gamut(rgb_space)
            end
          end

          def perceptually_map_to_gamut(rgb_space = nil)
            rgb_space = RGBSpaceResolver.call(self, rgb_space)
            return self if in_gamut?(rgb_space)

            lms = Sai.cache.fetch(self.class, :perceptually_map_to_gamut, identity, rgb_space) do
              lms         = to_lms.to_a
              wlms        = local_context.cone_transform.xyz_to_lms(local_context.white_point)
              nlms        = lms.to_a.zip(wlms).map { |r, w| r / w }

              max_normalized = nlms.max

              if max_normalized <= 1.0
                lms
              else
                scale_factor = 1.0 / max_normalized
                lms.map { |component| component * scale_factor }
              end
            end

            result = Physiological::LMS.from_intermediate(*lms, **local_context.to_h)
            rgb_result = result.to_rgb(rgb_space: rgb_space, map_to_gamut: false)
            rgb_result.in_gamut?(rgb_space) ? coerce(rgb_result) : coerce(rgb_result.clip_to_gamut(rgb_space))
          end

          def realizable?
            Sai.cache.fetch(self.class, :realizable?, identity) do
              x, y, z = to_xyz.to_a
              if [x, y, z].any?(&:negative?)
                false
              elsif y.zero?
                x.zero? && z.zero?
              else
                local_context.observer.chromaticity_coordinates.contains_chromaticity?(chromaticity)
              end
            end
          end

          def scale_to_gamut(rgb_space = nil)
            rgb_space = RGBSpaceResolver.call(self, rgb_space)
            return self if in_gamut?(rgb_space)

            rgb = Sai.cache.fetch(self.class, :scale_to_gamut, identity, rgb_space) do
              linear_rgb   = to_rgb(rgb_space:).to_a.map { |component| rgb_space.to_linear(component) }
              max_value    = linear_rgb.map(&:abs).max
              scale_factor = max_value > 1.0 ? 1.0 / max_value : 1.0

              linear_rgb.map { |component| rgb_space.from_linear(component * scale_factor) }
            end

            rgb_result = rgb_space.from_intermediate(*rgb)
            rgb_result.in_gamut?(rgb_space) ? coerce(rgb_result) : coerce(rgb_result.clip_to_gamut(rgb_space))
          end
        end
      end
    end
  end
end
