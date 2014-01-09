motion_require './_text_mixin.rb'
module MotionPrime
  module ElementContentTextMixin
    include ElementTextMixin

    def content_text
      is_a?(ButtonElement) ? button_content_text : input_content_text
    end

    def content_font
      (is_a?(ButtonElement) ? button_content_font : input_content_font) || :system.uifont
    end

    def content_attributed_text
      if view.try(:is_a?, UITextView) && view.text.present?
        text = view.attributedText
        text += ' ' if text.to_s.end_with?("\n") # does not respect \n at the end by default
        return text
      end

      string_options = {
        text: content_text,
        font: content_font,
        line_spacing: options[:line_spacing]
      }
      options[:html].present? ? html_string(string_options) : attributed_string(string_options)
    end

    def content_width
      min, max = options[:min_width].to_f, options[:max_width]
      return min if content_text.blank?

      rect = get_content_rect(Float::MAX)
      @content_width = [[rect.size.width.ceil, max].compact.min, min].max.ceil
    end

    def cached_content_width
      @content_width ||= content_width
    end

    def content_height
      min, max = options[:min_height].to_f, options[:max_height]
      return min if content_text.blank?
      rect = get_content_rect(options[:width] - content_padding_width)
      @content_height = [[rect.size.height.ceil, max].compact.min, min].max.ceil
    end

    def cached_content_height
      @content_height ||= content_height
    end

    private
      def get_content_rect(width)
        raise "Please set element width for content size calculation" unless width

        content_attributed_text.boundingRectWithSize(
          [width, Float::MAX], options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine, context:nil
        )
      end

      def button_content_text
        view ? view.titleLabel.text : options[:title]
      end

      def button_content_font
        options[:title_label].try(:[], :font)
      end

      def input_content_text
        input_value_text.blank? ? input_placeholder_text : input_value_text
      end

      def input_content_font
        input_value_text.blank? ? options[:placeholder_font] : options[:font]
      end

      def input_value_text
        view && !is_a?(DrawElement) ? view.text : (options[:html] || options[:text])
      end

      def input_placeholder_text
        options[:placeholder]
      end
  end
end