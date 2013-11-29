module MotionPrime
  class TextFieldElement < BaseElement
    include MotionPrime::ElementContentPaddingMixin
    include MotionPrime::ElementFieldDimensionsMixin
    
    def view_class
      "DMTextField"
    end
  end
end