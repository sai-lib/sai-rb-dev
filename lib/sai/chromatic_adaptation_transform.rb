# frozen_string_literal: true

module Sai
  class ChromaticAdaptationTransform < Matrix
    attr_reader :name

    def self.column_vector(*elements)
      result = super

      if result.to_a.size != 3
        raise DimensionMismatchError, "Matrix dimensions don't match: expected 3 columns, got: #{result.to_a.size}"
      end

      result
    end

    def self.row_vector(*elements)
      result = super

      if result.to_a.flatten.size != 3
        raise DimensionMismatchError, "Matrix dimensions don't match: expected 3 rows, got: #{result.to_a.size}"
      end

      result
    end

    def initialize(*rows)
      if rows.count != 3
        raise DimensionMismatchError, "Matrix dimensions don't match: expected 3 rows, got: #{rows.count}"
      end

      unless rows.all? { |row| row.size == 3 }
        raise DimensionMismatchError, "Matrix dimensions don't match: expected 3 columns, got: #{rows.map(&:count).max}"
      end

      super
    end

    def ==(other)
      super && name == other.name
    end

    def adapt(xyz, source_white:, target_white:)
      raise TypeError, "`:xyz` is invalid. Expected `Model::XYZ`, got: #{xyz.inspect}" unless xyz.is_a?(Model::XYZ)
      unless source_white.is_a?(Model::XYZ)
        raise TypeError, "`:source_white` is invalid. Expected `Model::XYZ`, got: #{source_white.inspect}"
      end
      unless target_white.is_a?(Model::XYZ)
        raise TypeError, "`:target_white` is invalid. Expected `Model::XYZ`, got: #{target_white.inspect}"
      end

      cache_key = [
        ChromaticAdaptationTransform,
        :adapt,
        *xyz.channel_cache_key,
        *source_white.channel_cache_key,
        *target_white.channel_cache_key,
      ]

      x, y, z =
        Sai.cache.fetch(*cache_key) do
          xyz_vector = self.class.column_vector(xyz)
          lms = self * xyz_vector

          source_white_vector = self.class.column_vector(source_white)
          source_white_lms = self * source_white_vector

          target_white_vector = self.class.column_vector(target_white)
          target_white_lms = self * target_white_vector

          lms_array = lms.to_a.flatten
          source_white_lms_array = source_white_lms.to_a.flatten
          target_white_lms_array = target_white_lms.to_a.flatten

          adapted_lms = lms_array.map.with_index do |value, i|
            value * (target_white_lms_array[i] / source_white_lms_array[i])
          end

          adapted_lms_vector = self.class.column_vector(adapted_lms)
          adapted_xyz_vector = inverse * adapted_lms_vector

          adapted_xyz_vector.to_a.flatten
        end

      Model::XYZ.new(x, y, z)
    end

    def inverse
      matrix = super
      matrix.instance_variable_set(:@inverted, true)
      matrix.instance_variable_set(:@name, "Inverted#{@name}")
      matrix
    end

    def inverted?
      @inverted || false
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

        pp.text('    ') # offset for row labels
        col_labels.each_with_index do |label, j|
          pp.text(' ') if j.positive?
          pp.text(label.rjust(widths[j]))
        end
        pp.breakable("\n")

        # Print rows with row labels
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
  end
end
