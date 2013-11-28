module MotionPrime
  module ElementFieldDimensionsMixin
    def text_value
      text = view ? view.text : computed_options[:text].to_s
      text.empty? ? computed_options[:placeholder] : text
    end

    def font
      computed_options[:font] || :system.uifont
    end

    def content_width
      min_width = computed_options[:min_width] || 20
      return min_width if text_value.to_s.empty?

      max_width = computed_options[:max_width] || Float::MAX

      attributed_text = NSAttributedString.alloc.initWithString(text_value, attributes: {NSFontAttributeName => font })
      rect = attributed_text.boundingRectWithSize([Float::MAX, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)

      width = rect.size.width.ceil
      [[width, max_width].min, min_width].max
    end

    def content_height
      text = view ? view.titleLabel.text : computed_options[:title]
      return 0 if text.blank?

      width = computed_options[:width]
      font = computed_options[:title_label][:font] || :system.uifont
      raise "Please set element width for height calculation" unless width

      attributes = {NSFontAttributeName => font }
      attributed_text = NSAttributedString.alloc.initWithString(text, attributes: attributes)
      rect = attributed_text.boundingRectWithSize([width, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)
      rect.size.height 
    end
  end
end
