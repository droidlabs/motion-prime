module MotionPrime
  class TextFieldElement < BaseElement
    include MotionPrime::ElementContentPaddingMixin
    include MotionPrime::ElementContentTextMixin

    def view_class
      "DMTextField"
    end
  end
end