# frozen_string_literal: true

module Sai
  module Enum
    module ChromaticAdaptationTransform
      extend Enum

      aliased_as :CAT

      value(:bradford) do
        Sai::ChromaticAdaptationTransform[
          [0.8951, 0.2664, -0.1614],
          [-0.7502, 1.7135, 0.0367],
          [0.0389, -0.0685, 1.0296],
        ].named('Bradford')
      end

      value(:cat02) do
        Sai::ChromaticAdaptationTransform[
          [0.7328, 0.4296, -0.1624],
          [-0.7036, 1.6975, 0.0061],
          [0.0030, 0.0136, 0.9834],
        ].named('CAT02')
      end

      value(:cat16) do
        Sai::ChromaticAdaptationTransform[
          [0.401288, 0.650173, -0.051461],
          [-0.250268, 1.204414, 0.045854],
          [-0.002079, 0.048952, 0.953127],
        ].named('CAT16')
      end

      value(:cmc_cat97) do
        Sai::ChromaticAdaptationTransform[
          [0.8951, 0.2664, -0.1614],
          [-0.7502, 1.7135, 0.0367],
          [0.0389, -0.0685, 1.0296],
        ].named('CMC CAT97')
      end

      value(:cmc_cat2000) do
        Sai::ChromaticAdaptationTransform[
          [0.7982, 0.3389, -0.1371],
          [-0.5918, 1.5512, 0.0406],
          [0.0008, 0.0239, 0.9753],
        ].named('CMC CAT2000')
      end

      value(:fairchild) do
        Sai::ChromaticAdaptationTransform[
          [0.8562, 0.3372, -0.1934],
          [-0.8360, 1.8327, 0.0033],
          [0.0357, -0.0469, 1.0112],
        ].named('Fairchild')
      end

      value(:hunt_pointer_estevez) do
        Sai::ChromaticAdaptationTransform[
          [0.38971, 0.68898, -0.07868],
          [-0.22981, 1.18340, 0.04641],
          [0.0, 0.0, 1.0],
        ].named('Hunt-Pointer-Estevez')
      end
      alias_value :hpe, :hunt_pointer_estevez

      value(:sharp) do
        Sai::ChromaticAdaptationTransform[
          [1.2694, -0.0988, -0.1706],
          [-0.8364, 1.8006, 0.0357],
          [0.0297, -0.0315, 1.0018],
        ].named('Sharp')
      end

      value(:von_kries) do
        Sai::ChromaticAdaptationTransform[
          [0.40024, 0.70760, -0.08081],
          [-0.22630, 1.16532, 0.04570],
          [0.00000, 0.00000, 0.91822],
        ].named('Von Kries')
      end

      value(:xyz_scaling) do
        Sai::ChromaticAdaptationTransform[
          [1.0, 0.0, 0.0],
          [0.0, 1.0, 0.0],
          [0.0, 0.0, 1.0],
        ].named('XYZ Scaling')
      end
    end
  end
end
