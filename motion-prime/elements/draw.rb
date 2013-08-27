module MotionPrime
  class DrawElement < BaseElement
    # MotionPrime::DrawElement is container for drawRect method options.
    # Elements are located inside Sections

    def render!
    end

    def view
      @view ||= section.container_view
    end

    def computed_max_width
      view.bounds.size.width
    end

    def computed_max_height
      view.bounds.size.height
    end

    def computed_padding_left
      computed_options[:padding_left] ||
      computed_options[:padding] || 0
    end

    def computed_padding_right
      computed_options[:padding_right] ||
      computed_options[:padding] || 0
    end

    def computed_padding_top
      computed_options[:padding_top] ||
      computed_options[:padding] || 0
    end

    def computed_padding_bottom
      computed_options[:padding_bottom] ||
      computed_options[:padding] || 0
    end

    def computed_width
      @computed_width ||= begin
        width = computed_options[:width]
        width = 0.0 if width.nil?

        # calculate width if width is relative, e.g 0.7
        if width > 0 && width <= 1
          width * computed_max_width
        else
          width > computed_max_width ? computed_max_width : width
        end
      end
    end

    # content width + content padding
    def computed_outer_width
      @computed_outer_width ||= begin
        computed_width + computed_padding_left + computed_padding_right
      end
    end

    def computed_height
      @computed_height ||= begin
        height = computed_options[:height]
        height = 0.0 if height.nil?

        # calculate height if height is relative, e.g 0.7
        if height > 0 && height <= 1
          height * computed_max_height
        else
          height > computed_max_height ? computed_max_height : height
        end
      end
    end

    # content height + content padding
    def computed_outer_height
      @computed_outer_height ||= begin
        computed_height + computed_padding_top + computed_padding_bottom
      end
    end

    def computed_left
      @computed_left ||= begin
        left = computed_options[:left]
        right = computed_options[:right]
        return left if left
        return 0 if right.nil?

        computed_max_width - (computed_width + right)
      end
    end

    # content left + content padding
    def computed_inner_left
      @computed_inner_left ||= begin
        computed_left + computed_padding_left
      end
    end

    def computed_top
      @computed_top ||= begin
        top = computed_options[:top]
        bottom = computed_options[:bottom]
        return top if top
        return 0 if bottom.nil?

        computed_max_height - (computed_height + bottom)
      end
    end

    # content top + content padding
    def computed_inner_top
      @computed_inner_top ||= begin
        computed_top + computed_padding_top
      end
    end

    def computed_bottom
      computed_options[:bottom] || 0
    end

    def computed_inner_bottom
      computed_bottom + computed_padding_bottom
    end

    def computed_right
      computed_options[:right] || 0
    end

    def computed_inner_right
      computed_right + computed_padding_right
    end

    def reset_computed_values
      [:left, :top, :right, :bottom, :width, :height].each do |key|
        instance_variable_set "@compited_#{key}", nil
        instance_variable_set "@compited_inner_#{key}", nil
      end
    end

    class << self
      def factory(type, options = {})
        class_name = "#{type.classify}DrawElement"
        "MotionPrime::#{class_name}".constantize.new(options)
      end
    end
  end
end