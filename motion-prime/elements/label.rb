module MotionPrime
  class LabelElement < BaseElement
    after_render :size_to_fit

    def size_to_fit
      if computed_options[:size_to_fit] || style_options[:size_to_fit]
        view.sizeToFit
      end
    end

    def height
      width = computed_options[:width]
      font = computed_options[:font] || :system.uifont
      raise "Please set element width for height calculation" unless width
      computed_options[:text].sizeWithFont(font,
            constrainedToSize: [width, Float::MAX],
            lineBreakMode:UILineBreakModeWordWrap).height
    end
  end
end