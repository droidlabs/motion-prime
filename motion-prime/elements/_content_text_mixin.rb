module MotionPrime
  module ElementContentTextMixin
    def content_text
      (is_a?(ButtonElement) ? button_content_text : input_content_text).to_s
    end

    def content_font
      (is_a?(ButtonElement) ? button_content_font : input_content_font) || :system.uifont
    end

    def content_width
      min, max = computed_options[:min_width].to_f, computed_options[:max_width]
      return min if content_text.blank?

      rect = get_content_rect(Float::MAX)
      [[rect.size.width.ceil, max].compact.min, min].max.ceil
    end

    def content_height
      min, max = computed_options[:min_height].to_f, computed_options[:max_height]
      return min if content_text.blank?
      rect = get_content_rect(computed_options[:width])
      [[rect.size.height.ceil, max].compact.min, min].max.ceil
    end

    private
      def get_content_rect(width)
        raise "Please set element width for content size calculation" unless width
        attributes = {NSFontAttributeName => content_font }
        if computed_options[:line_spacing]
          paragrahStyle = NSMutableParagraphStyle.alloc.init
          paragrahStyle.setLineSpacing(computed_options[:line_spacing])
          attributes[NSParagraphStyleAttributeName] = paragrahStyle
        end
        attributed_text = NSAttributedString.alloc.initWithString(content_text, attributes: attributes)
        attributed_text.boundingRectWithSize(
          [width, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin, context:nil
        )
      end

      def button_content_text
        view ? view.titleLabel.text : computed_options[:title]
      end

      def button_content_font
        computed_options[:title_label][:font]
      end

      def input_content_text
        input_value_text.blank? ? input_placeholder_text : input_value_text
      end

      def input_content_font
        input_value_text.blank? ? computed_options[:placeholder_font] : computed_options[:font]
      end

      def input_value_text
        view && !is_a?(DrawElement) ? view.text : computed_options[:text]
      end

      def input_placeholder_text
        computed_options[:placeholder]
      end
  end
end