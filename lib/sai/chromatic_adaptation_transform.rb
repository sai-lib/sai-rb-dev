# frozen_string_literal: true

module Sai
  class ChromaticAdaptationTransform < Core::Matrix
    extend  Core::DefferedConstant
    include Core::Concurrency
    include Core::Identity

    deffered_constant(:BRADFORD) do
      ChromaticAdaptationTransform[
        [0.8951, 0.2664, -0.1614],
        [-0.7502, 1.7135, 0.0367],
        [0.0389, -0.0685, 1.0296],
      ].named('Bradford')
    end

    deffered_constant(:CAT02) do
      ChromaticAdaptationTransform[
        [0.7328, 0.4296, -0.1624],
        [-0.7036, 1.6975, 0.0061],
        [0.0030, 0.0136, 0.9834],
      ].named('CAT02')
    end

    deffered_constant(:CAT16) do
      ChromaticAdaptationTransform[
        [0.401288, 0.650173, -0.051461],
        [-0.250268, 1.204414, 0.045854],
        [-0.002079, 0.048952, 0.953127],
      ].named('CAT16')
    end

    deffered_constant(:CMC_CAT97) do
      ChromaticAdaptationTransform[
        [0.8951, 0.2664, -0.1614],
        [-0.7502, 1.7135, 0.0367],
        [0.0389, -0.0685, 1.0296],
      ].named('CMC CAT97')
    end

    deffered_constant(:CMC_CAT2000) do
      Sai::ChromaticAdaptationTransform[
        [0.7982, 0.3389, -0.1371],
        [-0.5918, 1.5512, 0.0406],
        [0.0008, 0.0239, 0.9753],
      ].named('CMC CAT2000')
    end

    deffered_constant(:FAIRCHILD) do
      ChromaticAdaptationTransform[
        [0.8562, 0.3372, -0.1934],
        [-0.8360, 1.8327, 0.0033],
        [0.0357, -0.0469, 1.0112],
      ].named('Fairchild')
    end

    deffered_constant(:HUNT_POINTER_ESTEVEZ) do
      ChromaticAdaptationTransform[
        [0.38971, 0.68898, -0.07868],
        [-0.22981, 1.18340, 0.04641],
        [0.0, 0.0, 1.0],
      ].named('Hunt-Pointer-Estevez')
    end
    alias_deffered_constant :HPE, :HUNT_POINTER_ESTEVEZ

    deffered_constant(:SHARP) do
      ChromaticAdaptationTransform[
        [1.2694, -0.0988, -0.1706],
        [-0.8364, 1.8006, 0.0357],
        [0.0297, -0.0315, 1.0018],
      ].named('Sharp')
    end

    deffered_constant(:VON_KRIES) do
      ChromaticAdaptationTransform[
        [0.40024, 0.70760, -0.08081],
        [-0.22630, 1.16532, 0.04570],
        [0.00000, 0.00000, 0.91822],
      ].named('Von Kries')
    end

    deffered_constant(:XYZ_SCALING) do
      ChromaticAdaptationTransform[
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
      ].named('XYZ Scaling')
    end

    attr_reader :name

    def ==(other)
      other.is_a?(self.class) && other.identity == identity
    end

    def adapt(xyz, target_white:, source_white: nil)
      unless Model::XYZ === xyz
        raise TypeError, '`:xyz` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                         "`[Numeric, Numeric, Numeric]` got: #{xyz.inspect}"
      end
      unless Model::XYZ === target_white
        raise TypeError, '`:target_white` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                         "`[Numeric, Numeric, Numeric]` got: #{target_white.inspect}"
      end

      source_white ||= xyz.source_white if xyz.respond_to?(:source_white)
      source_white ||= [1, 1, 1].freeze

      unless Model::XYZ === source_white
        raise TypeError, '`:source_white` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                         "`[Numeric, Numeric, Numeric]` got: #{source_white.inspect}"
      end

      lms = xyz_to_lms(xyz)
      source_white_lms = xyz_to_lms(source_white)
      target_white_lms = xyz_to_lms(target_white)

      lms_array = lms.to_a.flatten
      source_white_lms_array = source_white_lms.to_a.flatten
      target_white_lms_array = target_white_lms.to_a.flatten

      adapted_lms = lms_array.map.with_index do |value, i|
        value * (target_white_lms_array[i] / source_white_lms_array[i])
      end

      lms_to_xyz(adapted_lms).to_a.flatten
    end

    def inverse
      matrix = super

      matrix.send(:mutex).synchronize do
        matrix.instance_variable_set(:@inverted, true)
        matrix.instance_variable_set(:@name, "Inverted#{name}")
      end

      matrix
    end

    def inverted?
      concurrent_instance_variable_fetch(:@inverted, false)
    end

    def lms_to_xyz(lms)
      unless Model::LMS === lms
        raise TypeError, '`:lms` is invalid. Expected an object that implements `Sai::Model::LMS` or ' \
                         "`[Numeric, Numeric, Numeric]` got: #{lms.inspect}"
      end

      vector = self.class.column_vector(lms)
      (inverse * vector).to_a.flatten
    end

    def named(name)
      @name = name
      self
    end

    def pretty_print(pp)
      pp.group(1, (@name || self.class).to_s) do
        return if @rows.empty?

        row_labels = inverted? ? %w[:l :m :s] : %w[:x :y :z]
        col_labels = inverted? ? %w[:x :y :z] : %w[:l :m :s]

        widths = Array.new(column_count, 0)

        @rows.each do |row|
          row.each_with_index do |val, j|
            val_str = val.nil? ? 'nil' : val.to_s
            widths[j] = [widths[j], val_str.length].max
          end
        end

        col_labels.each_with_index do |label, j|
          widths[j] = [widths[j], label.length].max
        end

        pp.breakable("\n")

        pp.text('    ')
        col_labels.each_with_index do |label, j|
          pp.text(' ') if j.positive?
          pp.text(label.rjust(widths[j]))
        end
        pp.breakable("\n")

        @rows.each_with_index do |row, i|
          pp.text(row_labels[i].ljust(3))
          pp.text(' ')
          row.each_with_index do |val, j|
            val_str = val.nil? ? 'nil' : val.to_s
            pp.text(' ') if j.positive?
            pp.text(val_str.rjust(widths[j]))
          end
          pp.breakable("\n") if i < @rows.size - 1
        end

        pp.breakable("\n")
      end
    end

    def xyz_to_lms(xyz)
      unless Model::XYZ === xyz
        raise TypeError, '`:xyz` is invalid. Expected an object that implements `Sai::Model::XYZ` or ' \
                         "`[Numeric, Numeric, Numeric]` got: #{xyz.inspect}"
      end

      vector = self.class.column_vector(xyz)
      (self * vector).to_a.flatten
    end

    private

    def identity_attributes
      [self.class, name, to_a].freeze
    end
  end

  CAT = ChromaticAdaptationTransform
end
