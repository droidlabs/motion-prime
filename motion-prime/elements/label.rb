module MotionPrime
  class LabelElement < BaseElement
    include MotionPrime::ElementContentPaddingMixin
    include MotionPrime::ElementContentTextMixin

    before_render :size_to_fit_if_needed
    after_render :size_to_fit

    def view_class
      "MPLabel"
    end

    def size_to_fit
      if options[:size_to_fit]
        if options[:width]
          view.setHeight([cached_content_outer_height, options[:height]].compact.min)
        else
          view.sizeToFit
          # we should re-set values, because sizeToFit do not use padding
          view.setWidth(view.bounds.size.width + content_padding_width)
          view.setHeight(view.bounds.size.height + content_padding_height)
        end
      end
    end

    def size_to_fit_if_needed
      if options[:size_to_fit] && options[:width]
        options[:height_to_fit] = cached_content_outer_height
      end
    end
  end
end