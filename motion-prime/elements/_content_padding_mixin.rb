module MotionPrime
  module ElementContentPaddingMixin
    def content_padding_left
      computed_options[:padding_left] ||
        computed_options[:padding] ||
        default_padding_for(:left) || 0
    end

    def content_padding_right
      computed_options[:padding_right] ||
        computed_options[:padding] ||
        default_padding_for(:right) || 0
    end

    def content_padding_top
      computed_options[:padding_top] ||
        computed_options[:padding] ||
        default_padding_for(:top) || 0
    end

    def content_padding_bottom
      computed_options[:padding_bottom] ||
        computed_options[:padding] ||
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
      [[height, computed_options[:min_outer_height]].compact.max, computed_options[:max_outer_height]].compact.min
    end

    def cached_content_outer_height
      content_outer_height(true)
    end

    def content_outer_width(cached = false)
      width = content_padding_width + (cached ? cached_content_width : content_width)
      [[width, computed_options[:min_outer_width]].compact.max, computed_options[:max_outer_width]].compact.min
    end

    def cached_content_outer_width
      content_outer_width(true)
    end

    def default_padding_for(side)
      view_class.constantize.send(:"default_padding_#{side}")
    end
  end
end