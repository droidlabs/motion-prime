module MotionPrime
  module ElementContentPaddingMixin
    def content_padding_left
      options[:padding_left] ||
        options[:padding] ||
        default_padding_for(:left) || 0
    end

    def content_padding_right
      options[:padding_right] ||
        options[:padding] ||
        default_padding_for(:right) || 0
    end

    def content_padding_top
      options[:padding_top] ||
        options[:padding] ||
        default_padding_for(:top) || 0
    end

    def content_padding_bottom
      options[:padding_bottom] ||
        options[:padding] ||
        default_padding_for(:bottom) || 0
    end

    def content_padding_height
      content_padding_top + content_padding_bottom
    end

    def content_padding_width
      content_padding_left + content_padding_right
    end

    def content_outer_height(cached = false)
      height = content_padding_height + (cached ? cached_content_height : content_height)
      [[height, options[:min_outer_height]].compact.max, options[:max_outer_height]].compact.min
    end

    def cached_content_outer_height
      content_outer_height(true)
    end

    def content_outer_width(cached = false)
      width = content_padding_width + (cached ? cached_content_width : content_width)
      [[width, options[:min_outer_width]].compact.max, options[:max_outer_width]].compact.min
    end

    def cached_content_outer_width
      content_outer_width(true)
    end

    def default_padding_for(side)
      class_factory(view_class).send(:"default_padding_#{side}")
    end
  end
end