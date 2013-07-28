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

    def computed_width
      width = computed_options[:width]
      width = 0.0 if width.nil?

      # calculate width if width is relative, e.g 0.7
      if width > 0 && width <= 1
        width * computed_max_width
      else
        width > computed_max_width ? computed_max_width : width
      end
    end

    def computed_height
      height = computed_options[:height]
      height = 0.0 if height.nil?

      # calculate height if height is relative, e.g 0.7
      if height > 0 && height <= 1
        height * computed_max_height
      else
        height > computed_max_height ? computed_max_height : height
      end
    end

    def computed_left
      left = computed_options[:left]
      right = computed_options[:right]
      return left if left
      return 0 if right.nil?

      computed_max_width - (computed_width + right)
    end

    def computed_top
      top = computed_options[:top]
      bottom = computed_options[:bottom]
      return top if top
      return 0 if bottom.nil?

      computed_max_height - (computed_height + bottom)
    end

    class << self
      def factory(type, options = {})
        class_name = "#{type.classify}DrawElement"
        "MotionPrime::#{class_name}".constantize.new(options)
      end
    end
  end
end