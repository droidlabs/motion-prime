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

      options = {
        text: content_text,
        font: content_font,
        line_spacing: computed_options[:line_spacing]
      }
      computed_options[:html].present? ? html_string(options) : attributed_string(options)
    end

    def content_width
      min, max = computed_options[:min_width].to_f, computed_options[:max_width]
      return min if content_text.blank?

      rect = get_content_rect(Float::MAX)
      @content_width = [[rect.size.width.ceil, max].compact.min, min].max.ceil
    end

    def cached_content_width
      @content_width ||= content_width
    end

    def content_height
      min, max = computed_options[:min_height].to_f, computed_options[:max_height]
      return min if content_text.blank?
      rect = get_content_rect(computed_options[:width] - content_padding_width)
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
        view ? view.titleLabel.text : computed_options[:title]
      end

      def button_content_font
        computed_options[:title_label].try(:[], :font)
      end

      def input_content_text
        input_value_text.blank? ? input_placeholder_text : input_value_text
      end

      def input_content_font
        input_value_text.blank? ? computed_options[:placeholder_font] : computed_options[:font]
      end

      def input_value_text
        view && !is_a?(DrawElement) ? view.text : (computed_options[:html] || computed_options[:text])
      end

      def input_placeholder_text
        computed_options[:placeholder]
      end
  end
end