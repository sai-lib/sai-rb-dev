# frozen_string_literal: true

module Sai
  module Space
    module Physiological
      class LMS < Base
        implements Model::LMS

        def to_lms(**options)
          convert_to_self(**options)
        end

        def to_xyz(**options)
          convert_to(XYZ, **options) { |context| context.cone_transform.lms_to_xyz(with_context(**context.to_h)) }
        end
      end
    end
  end
end
