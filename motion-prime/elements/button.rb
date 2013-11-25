module MotionPrime
  class ButtonElement < BaseElement
    include MotionPrime::ElementFieldDimensionsMixin

    after_render :size_to_fit

    def size_to_fit
      if computed_options[:size_to_fit] || style_options[:size_to_fit]
        if computed_options[:width]
          view.setHeight computed_height
        end
      end
    end

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