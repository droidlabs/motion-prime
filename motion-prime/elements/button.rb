module MotionPrime
  class ButtonElement < BaseElement
    include MotionPrime::ElementFieldDimensionsMixin

    def view_class
      "DMButton"
    end

    def text_value
      view.try(:currentTitle) || computed_options[:title]
    end

    def font
      computed_options[:title_label].try(:[], :font) || :system.uifont
    end
  end
end