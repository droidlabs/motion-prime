module MotionPrime
  module ElementTextHeightMixin
    def content_height
      text = computed_options[:text]
      return 0 if text.blank?

      width = computed_options[:width]
      font = computed_options[:font] || :system.uifont
      raise "Please set element width for height calculation" unless width

      attributes = {NSFontAttributeName => font }
      if computed_options[:line_spacing]
        paragrahStyle = NSMutableParagraphStyle.alloc.init
        paragrahStyle.setLineSpacing(computed_options[:line_spacing])
        attributes[NSParagraphStyleAttributeName] = paragrahStyle
      end
      attributed_text = NSAttributedString.alloc.initWithString(computed_options[:text], attributes: attributes)
      rect = attributed_text.boundingRectWithSize([width, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)

      rect.size.height
    end

    def content_width
      text = computed_options[:text]
      return 0 if text.blank?

      width = computed_options[:width]
      font = computed_options[:font] || :system.uifont

      attributed_text = NSAttributedString.alloc.initWithString(computed_options[:text], attributes: {NSFontAttributeName => font })
      rect = attributed_text.boundingRectWithSize([Float::MAX, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)

      rect.size.width
    end

    def content_outer_height
      content_height + computed_inner_top + computed_inner_bottom
    end
  end
end