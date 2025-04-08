# frozen_string_literal: true

module Sai
  class Matrix
    autoload :Conversion, 'sai/matrix/conversion'
    autoload :Vector,     'sai/matrix/vector'

    attr_reader :column_count
    attr_reader :row_count

    include Conversion

    class << self
      include Conversion

      def [](*rows)
        new(*rows)
      end

      def column_vector(*elements)
        elements = elements.flatten
        Vector.column(*elements)
      end

      def from_column_vector(*elements)
        elements = convert_to_array(elements.flatten)
        new(*[*elements].transpose)
      end

      def from_row_vector(*elements)
        elements = convert_to_array(elements.flatten)
        new(*elements)
      end

      def row_vector(*elements)
        elements = elements.flatten
        Vector.row(*elements)
      end
    end

    def initialize(*rows)
      @rows = rows.map { |column| convert_to_array(column, copy: true).freeze }.freeze
      @row_count = @rows.size
      @column_count = @rows.map(&:size).max
    end

    def *(other)
      if other.is_a?(Numeric)
        scalar_result = @rows.map { |row| row.map { |value| value * other } }
        return self.class.new(*scalar_result)
      end

      other = convert_to_array(other)

      if column_count != other.size
        raise DimensionMismatchError,
              "Matrix dimensions don't match for multiplication: #{column_count} columns != #{other.size} rows"
      end

      result = Array.new(row_count) { Array.new(other.first.size, 0) }

      row_count.times do |i|
        other.first.size.times do |j|
          sum = 0
          column_count.times do |k|
            sum += @rows[i][k] * other[k][j]
          end
          result[i][j] = sum
        end
      end

      resolve_result(other, result)
    end

    def +(other)
      other = convert_to_array(other)
      unless row_count == other.size && column_count == other.first&.size
        raise DimensionMismatchError,
              "Matrix dimensions don't match: #{row_count}x#{column_count} vs #{other.size}x#{other.first&.size}"
      end

      addition_result = @rows.map.with_index do |row, i|
        row.map.with_index { |value, j| value + other[i][j] }
      end

      resolve_result(other, addition_result)
    end

    def -(other)
      other = convert_to_array(other)
      unless row_count == other.size && column_count == other.first&.size
        raise DimensionMismatchError,
              "Matrix dimensions don't match: #{row_count}x#{column_count} vs #{other.size}x#{other.first&.size}"
      end

      subtraction_result = @rows.map.with_index do |row, i|
        row.map.with_index { |value, j| value - other[i][j] }
      end

      resolve_result(other, subtraction_result)
    end

    def /(other)
      if other.is_a?(Numeric)
        raise ZeroDivisionError, 'Division by zero' if other.zero?

        division_result = @rows.map { |row| row.map { |value| value / other } }
        return self.class.new(*division_result)
      end

      other = convert_to_array(other)

      raise DimensionMismatchError, 'Can only divide by square matrices' if other.size != other.first.size

      inverse_matrix = other.is_a?(Matrix) ? other.inverse : Matrix.new(*other).inverse
      self * inverse_matrix
    end

    def ==(other)
      other.is_a?(self.class) && to_a == other.to_a
    end

    def [](row, column = nil)
      if column.nil?
        self.row(row)
      else
        @rows[row][column]
      end
    end

    def column(index)
      Vector.column(@rows.map { |row| row[index] })
    end

    def determinant
      raise DimensionMismatchError unless square?

      m = @rows
      case row_count
      when 0
        +1
      when 1
        + m[0][0]
      when 2
        (+ m[0][0] * m[1][1]) - (m[0][1] * m[1][0])
      when 3
        m0, m1, m2 = m
        (+ m0[0] * m1[1] * m2[2]) - (m0[0] * m1[2] * m2[1]) \
          - (m0[1] * m1[0] * m2[2]) + (m0[1] * m1[2] * m2[0]) \
          + (m0[2] * m1[0] * m2[1]) - (m0[2] * m1[1] * m2[0])
      when 4
        m0, m1, m2, m3 = m
        (+ m0[0] * m1[1] * m2[2] * m3[3]) - (m0[0] * m1[1] * m2[3] * m3[2]) \
          - (m0[0] * m1[2] * m2[1] * m3[3]) + (m0[0] * m1[2] * m2[3] * m3[1]) \
          + (m0[0] * m1[3] * m2[1] * m3[2]) - (m0[0] * m1[3] * m2[2] * m3[1]) \
          - (m0[1] * m1[0] * m2[2] * m3[3]) + (m0[1] * m1[0] * m2[3] * m3[2]) \
          + (m0[1] * m1[2] * m2[0] * m3[3]) - (m0[1] * m1[2] * m2[3] * m3[0]) \
          - (m0[1] * m1[3] * m2[0] * m3[2]) + (m0[1] * m1[3] * m2[2] * m3[0]) \
          + (m0[2] * m1[0] * m2[1] * m3[3]) - (m0[2] * m1[0] * m2[3] * m3[1]) \
          - (m0[2] * m1[1] * m2[0] * m3[3]) + (m0[2] * m1[1] * m2[3] * m3[0]) \
          + (m0[2] * m1[3] * m2[0] * m3[1]) - (m0[2] * m1[3] * m2[1] * m3[0]) \
          - (m0[3] * m1[0] * m2[1] * m3[2]) + (m0[3] * m1[0] * m2[2] * m3[1]) \
          + (m0[3] * m1[1] * m2[0] * m3[2]) - (m0[3] * m1[1] * m2[2] * m3[0]) \
          - (m0[3] * m1[2] * m2[0] * m3[1]) + (m0[3] * m1[2] * m2[1] * m3[0])
      else
        size = row_count
        last = size - 1
        a = to_a
        no_pivot = proc { return 0 }
        sign = +1
        pivot = 1
        size.times do |k|
          previous_pivot = pivot
          if (pivot = a[k][k]).zero?
            switch = (k + 1...size).find(no_pivot) do |row|
              a[row][k] != 0
            end
            a[switch], a[k] = a[k], a[switch]
            pivot = a[k][k]
            sign = -sign
          end
          (k + 1).upto(last) do |i|
            ai = a[i]
            (k + 1).upto(last) do |j|
              ai[j] = ((pivot * ai[j]) - (ai[k] * a[k][j])) / previous_pivot
            end
          end
        end
        sign * pivot
      end
    end
    alias det determinant

    def inverse
      raise DimensionMismatchError unless square?

      if row_count == 1
        return self.class.new([1.0 / @rows[0][0]])
      elsif row_count == 2
        a = @rows[0][0].to_f
        b = @rows[0][1].to_f
        c = @rows[1][0].to_f
        d = @rows[1][1].to_f

        det = (a * d) - (b * c)
        raise ZeroDeterminantError if det.abs < 1e-10

        return self.class.new(
          [d / det, -b / det],
          [-c / det, a / det],
        )
      end

      n = row_count
      det = determinant
      raise ZeroDeterminantError if det.abs < 1e-10

      matrix = @rows.map { |row| row.map(&:to_f) }
      identity = Array.new(n) { |i| Array.new(n) { |j| i == j ? 1.0 : 0.0 } }

      n.times do |k|
        pivot_row = k
        max_val = matrix[k][k].abs

        ((k + 1)...n).each do |i|
          if matrix[i][k].abs > max_val
            max_val = matrix[i][k].abs
            pivot_row = i
          end
        end

        if pivot_row != k
          matrix[k], matrix[pivot_row] = matrix[pivot_row], matrix[k]
          identity[k], identity[pivot_row] = identity[pivot_row], identity[k]
        end

        pivot = matrix[k][k]
        raise ZeroDeterminantError, 'Matrix is singular' if pivot.abs < 1e-10

        n.times do |j|
          matrix[k][j] /= pivot
          identity[k][j] /= pivot
        end

        n.times do |i|
          next if i == k

          factor = matrix[i][k]
          n.times do |j|
            matrix[i][j] -= factor * matrix[k][j]
            identity[i][j] -= factor * identity[k][j]
          end
        end
      end

      self.class.new(*identity)
    end

    def pretty_print(pp)
      pp.group(1, "#{self.class}[", ']') do
        return if @rows.empty?

        widths = Array.new(column_count, 0)
        @rows.each do |row|
          row.each_with_index do |val, j|
            val_str = val.nil? ? 'nil' : val.to_s
            widths[j] = [widths[j], val_str.length].max
          end
        end

        pp.breakable("\n")

        @rows.each_with_index do |row, i|
          pp.text('  ')
          row.each_with_index do |val, j|
            pp.text(' ') if j.positive?
            val_str = val.nil? ? 'nil' : val.to_s
            pp.text(val_str.rjust(widths[j]))
          end

          pp.breakable("\n") if i < @rows.size - 1
        end

        pp.breakable("\n")
      end
    end

    # @return [Vector] the row
    def row(index)
      Vector.row(@rows[index])
    end

    def square?
      row_count == column_count
    end

    def to_array
      @rows.map(&:dup)
    end
    alias to_a   to_array
    alias to_ary to_array

    def transpose
      self.class.new(*@rows.transpose)
    end

    private

    def resolve_result(other, result)
      return self.class.new(*result) if other.is_a?(Matrix)
      return Vector.new(*result, orientation: other.orientation) if other.is_a?(Vector)

      result
    end
  end
end
