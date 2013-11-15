motion_require './label'
module MotionPrime
  class ErrorMessageElement < LabelElement
    include MotionPrime::ElementTextDimensionsMixin

    def view_class
      "UILabel"
    end
  end
end