module MotionPrime
  module ElementContentPaddingMixin
    def content_padding_left
      computed_options[:padding_left] ||
      computed_options[:padding] || view.try(:default_padding_left) || 0
    end

    def content_padding_right
      computed_options[:padding_right] ||
      computed_options[:padding] || view.try(:default_padding_right) || 0
    end

    def content_padding_top
      computed_options[:padding_top] ||
      computed_options[:padding] || view.try(:default_padding_top) || 0
    end

    def content_padding_bottom
      computed_options[:padding_bottom] ||
      computed_options[:padding] || view.try(:default_padding_bottom) || 0
    end

    def content_padding_height
      content_padding_top + content_padding_bottom
    end

    def content_padding_width
      content_padding_left + content_padding_right
    end

    def content_outer_height
      content_padding_height + content_height
    end

    def content_outer_width
      content_padding_width + content_width
    end
  end
end