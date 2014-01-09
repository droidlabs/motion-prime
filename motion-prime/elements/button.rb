module MotionPrime
  class ButtonElement < BaseElement
    include MotionPrime::ElementContentPaddingMixin
    include MotionPrime::ElementContentTextMixin

    after_render :size_to_fit

    def size_to_fit
      if options[:size_to_fit]
        if options[:width]
          view.setHeight cached_content_outer_height
        end
      end
    end

    def view_class
      "MPButton"
    end

    def text_value
      view.try(:currentTitle) || options[:title]
    end

    def font
      options[:title_label].try(:[], :font) || :system.uifont
    end
  end
end