module MotionPrime
  class LabelElement < BaseElement
    include ElementContentPaddingMixin
    include ElementContentTextMixin
    include ElementTextMixin

    before_render :size_to_fit_if_needed
    after_render :size_to_fit

    def view_class
      "MPLabel"
    end

    def size_to_fit
      if computed_options[:size_to_fit]
        if computed_options[:width]
          view.setHeight([cached_content_outer_height, computed_options[:height]].compact.min)
        else
          view.sizeToFit
          # we should re-set values, because sizeToFit do not use padding
          view.setWidth(view.bounds.size.width + content_padding_width)
          view.setHeight(computed_options[:height] || (view.bounds.size.height + content_padding_height))
        end
      end
    end

    def size_to_fit_if_needed
      if computed_options[:size_to_fit] && computed_options[:width]
        @computed_options[:height_to_fit] = content_outer_height
      end
    end

    def set_text(value)
      options[:text] = computed_options[:text] = value
      styler = ViewStyler.new(view, CGRectZero, computed_options)
      if styler.options[:attributed_text]
        view.attributedText = styler.options[:attributed_text]
      else
        view.text = value
      end
      @content_height = nil
      size_to_fit
    end
  end
end