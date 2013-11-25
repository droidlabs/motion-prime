module MotionPrime
  module ElementFieldDimensionsMixin
    def text_value
      text = view ? view.text : computed_options[:text].to_s
      text.empty? ? computed_options[:placeholder] : text
    end

    def font
      computed_options[:font] || :system.uifont
    end

    def computed_width
      min_width = computed_options[:min_width] || 20
      return min_width if text_value.to_s.empty?

      padding_left = view.try(:padding_left) || computed_options[:padding_left] || computed_options[:padding] || view_class.constantize::DEFAULT_PADDING_LEFT
      padding_right = view.try(:padding_right) || computed_options[:padding_right] || padding_left
      max_width = computed_options[:max_width] || Float::MAX

      attributed_text = NSAttributedString.alloc.initWithString(text_value, attributes: {NSFontAttributeName => font })
      rect = attributed_text.boundingRectWithSize([Float::MAX, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)

      width = (rect.size.width + padding_left + padding_right).ceil
      [[width, max_width].min, min_width].max
    end

    def computed_height
      text = view ? view.titleLabel.text : computed_options[:title]
      return 0 if text.blank?

      width = computed_options[:width]
      font = computed_options[:title_label][:font] || :system.uifont
      raise "Please set element width for height calculation" unless width

      attributes = {NSFontAttributeName => font }
      attributed_text = NSAttributedString.alloc.initWithString(text, attributes: attributes)
      rect = attributed_text.boundingRectWithSize([width, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil)

      padding_top = computed_options[:padding_top] || computed_options[:padding] || view.try(:default_padding_top)
      rect.size.height + padding_top*2
    end
  end
end
