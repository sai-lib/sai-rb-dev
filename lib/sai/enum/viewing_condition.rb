# frozen_string_literal: true

module Sai
  module Enum
    module ViewingCondition
      extend Enum

      module SurroundType
        extend Enum

        value(:average) do
          Sai::ViewingCondition::Surround.new(
            chromatic_induction_factor: 1.0,
            factor: 1.0,
            impact_factor: 0.69,
          )
        end

        value(:dim) do
          Sai::ViewingCondition::Surround.new(
            chromatic_induction_factor: 0.95,
            factor: 0.9,
            impact_factor: 0.59,
          )
        end

        value(:dark) do
          Sai::ViewingCondition::Surround.new(
            chromatic_induction_factor: 0.8,
            factor: 0.8,
            impact_factor: 0.525,
          )
        end
      end

      value(:cinema_environment) do
        Sai::ViewingCondition.load('viewing_condition/cinema_environment.yml', symbolize_names: true)
      end

      value(:dark_room_display) do
        Sai::ViewingCondition.load('viewing_condition/dark_room_display.yml', symbolize_names: true)
      end

      value(:dark_room_print) do
        Sai::ViewingCondition.load('viewing_condition/dark_room_print.yml', symbolize_names: true)
      end

      value(:dim_room_display) do
        Sai::ViewingCondition.load('viewing_condition/dim_room_display.yml', symbolize_names: true)
      end

      value(:dim_room_print) do
        Sai::ViewingCondition.load('viewing_condition/dim_room_print.yml', symbolize_names: true)
      end

      value(:fluorescent_office) do
        Sai::ViewingCondition.load('viewing_condition/fluorescent_office.yml', symbolize_names: true)
      end

      value(:high_brightness_display) do
        Sai::ViewingCondition.load('viewing_condition/high_brightness_display.yml', symbolize_names: true)
      end

      value(:mobile_device) { Sai::ViewingCondition.load('viewing_condition/mobile_device.yml', symbolize_names: true) }

      value(:print_proofing) do
        Sai::ViewingCondition.load('viewing_condition/print_proofing.yml', symbolize_names: true)
      end

      value(:retail_lighting) do
        Sai::ViewingCondition.load('viewing_condition/retail_lighting.yml', symbolize_names: true)
      end

      value(:srgb_reference) do
        Sai::ViewingCondition.load('viewing_condition/srgb_reference.yml', symbolize_names: true)
      end

      value(:standard_display_d65) do
        Sai::ViewingCondition.load('viewing_condition/standard_display.yml', symbolize_names: true)
      end
      alias_value :standard_display, :standard_display_d65

      value(:standard_print_d50) do
        Sai::ViewingCondition.load('viewing_condition/standard_print.yml', symbolize_names: true)
      end
      alias_value :standard_print, :standard_print_d50

      value(:tungsten_dark) { Sai::ViewingCondition.load('viewing_condition/tungsten_dark.yml', symbolize_names: true) }

      value(:tungsten_dim) { Sai::ViewingCondition.load('viewing_condition/tungsten_dim.yml', symbolize_names: true) }

      value(:tungsten_standard) do
        Sai::ViewingCondition.load('viewing_condition/tungsten_standard.yml', symbolize_names: true)
      end
    end
  end
end
