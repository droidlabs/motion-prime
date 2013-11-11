module MotionPrime
  module ElementFieldDimensionsMixin
    def text_value
      view.try(:text) || computed_options[:text] || computed_options[:placeholder]
    end

    def font
      computed_options[:font] || :system.uifont
    end

    def computed_width
      return 0 if text_value.blank?
      puts font.pointSize
      puts padding_left = view.try(:padding_left) || computed_options[:padding_left] || computed_options[:padding] || view_class.constantize::DEFAULT_PADDING_LEFT
      puts padding_right = view.try(:padding_right) || computed_options[:padding_right] || padding_left
      max_width = computed_options[:max_width] || Float::MAX

      attributed_text = NSAttributedString.alloc.initWithString(text_value, attributes: {NSFontAttributeName => font })
      rect = attributed_text.boundingRectWithSize([Float::MAX, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)

      [(rect.size.width + padding_left + padding_right).ceil, max_width].min
    end
  end
end
