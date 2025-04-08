# frozen_string_literal: true

module Sai
  class Matrix
    module Conversion
      private

      def convert_to_array(object, copy: false)
        case object
        when Array then copy ? object.dup : object
        when Vector then copy ? object.to_a.dup : object.to_a
        when Model then copy ? object.to_n_a.dup : object.to_n_a
        else
          begin
            converted = object.to_ary.dup
          rescue StandardError
            raise TypeError, "`object` is invalid. Expected `Array | #to_ary`, got: #{object.inspect}"
          end
          unless converted.is_a? Array
            raise TypeError, "`object` is invalid. Expected `Array | #to_ary`, got: #{object.inspect}"
          end

          converted
        end
      end
    end
    private_constant :Conversion
  end
end
