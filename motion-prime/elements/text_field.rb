module MotionPrime
  class TextFieldElement < BaseElement
    include MotionPrime::ElementContentPaddingMixin
    include MotionPrime::ElementContentTextMixin

    def view_class
      "MPTextField"
    end
  end
end