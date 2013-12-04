module MotionPrime
  class TextViewElement < BaseElement
    include MotionPrime::ElementContentPaddingMixin
    include MotionPrime::ElementContentTextMixin
    
    def view_class
      "DMTextView"
    end
  end
end