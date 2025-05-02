# frozen_string_literal: true

module Sai
  module Core
    class Matrix
      autoload :Vector, 'sai/core/matrix/vector'

      include Enumerable

      attr_reader :column_count
      attr_reader :row_count

      class << self
        def [](*rows)
          new(*rows)
        end

        def column_vector(*elements)
          Vector.column(*elements.flatten)
        end

        def row_vector(*elements)
          Vector.row(*elements.flatten)
        end
      end

      def initialize(*rows)
        @rows         = rows.map { |column| convert_to_array(column).freeze }.freeze
        @row_count    = @rows.size
        @column_count = @rows.map(&:size).max
      end

      def *(other)
        if other.is_a?(Numeric)
          new_rows = @rows.map { |row| row.map { |value| value * other } }
          return self.class.new(*new_rows)
        end

        array = convert_to_array(other)

        if column_count != array.size
          raise DimensionMismatchError,
                "Matrix dimensions don't match for multiplication: #{column_count} columns != #{array.size} rows"
        end

        result = Array.new(row_count) { Array.new(array.first.size, 0) }

        row_count.times do |i|
          array.first.size.times do |j|
            sum = 0.0
            column_count.times { |k| sum += @rows[i][k].to_f * array[k][j].to_f }
            result[i][j] = sum
          end
        end

        self.class.new(*result)
      end

      def +(other)
        array = convert_to_array(other)

        unless row_count == array.size && column_count == array.first&.size
          raise DimensionMismatchError, "Matrix dimensions don't match: #{row_count}x#{column_count} vs " \
                                        "#{array.size}x#{array.first&.size}"
        end

        result = @rows.map.with_index do |row, i|
          row.map.with_index { |value, j| value + array[i][j] }
        end

        self.class.new(*result)
      end

      def -(other)
        array = convert_to_array(other)

        unless row_count == array.size && column_count == array.first&.size
          raise DimensionMismatchError, "Matrix dimensions don't match: #{row_count}x#{column_count} vs " \
                                        "#{array.size}x#{array.first&.size}"
        end

        result = @rows.map.with_index do |row, i|
          row.map.with_index { |value, j| value - array[i][j] }
        end

        self.class.new(*result)
      end

      def /(other)
        result = case other
                 when Numeric
                   raise ZeroDivisionError, 'Division by zero' if other.zero?

                   @rows.map { |row| row.map { |value| value / other } }
                 when Matrix
                   raise DimensionMismatchError, 'Can only divide by square matrices' unless other.square?

                   self * other.inverse
                 else
                   array = convert_to_array(other)
                   unless array.size == array.first.size
                     raise DimensionMismatchError, 'Can only divide by square matrices'
                   end

                   self * self.class[*array].inverse
                 end
        result.is_a?(Matrix) ? result : self.class.new(*convert_to_array(result))
      end

      def ==(other)
        self.class === other && column_count == other.column_count && @rows == other.instance_variable_get(:@rows)
      end

      def [](row_index, column_index = nil)
        column_index.nil? ? row(row_index) : @rows[row_index][column_index]
      end

      def collect(&)
        return to_enum(:collect) unless block_given?

        dup.collect!(&)
      end
      alias map collect

      def column(index)
        Vector.column(*@rows.map { |row| row[index] })
      end

      def column_vector(...)
        self.class.column_vector(...)
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

      def each(&)
        return to_enum(:each) unless block_given?

        @rows.each { |row| row.each(&) }
        self
      end

      def eql?(other)
        Matrix === other && column_count == other.column_count && @rows.eql?(other.instance_variable_get(:@rows))
      end

      def hash
        @rows.hash
      end

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

      def row(index)
        Vector.row(*@rows[index])
      end

      def row_vector(...)
        self.class.row_vector(...)
      end

      def serialize
        to_array
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

      def convert_to_array(object)
        case object
        when Array          then object.dup
        when Matrix, Vector then object.to_a.dup
        else
          begin
            converted = object.respond_to?(:to_a) ? object.to_a : object.to_ary
          rescue StandardError
            raise TypeError, "`object` is invalid. Expected `Array | #to_a | #to_ary`, got: #{object.inspect}"
          end
          unless converted.is_a?(Array)
            raise TypeError, "`object` is invalid. Expected `Array | #to_a | #to_ary`, got: #{object.inspect}"
          end

          converted
        end
      end
    end
  end
end

Sai.events.emit_load(Sai::Core::Matrix)
