module MotionPrime
  class DrawElement < BaseElement
    # MotionPrime::DrawElement is container for drawRect method options.
    # Elements are located inside Sections

    def render!
    end

    def view
      @view ||= section.container_view
    end

    def computed_left
      width = computed_options[:width]
      left = computed_options[:left]
      right = computed_options[:right]
      return left if left
      return 0 if right.nil?

      width = 0.0 if width.nil?
      max_width = view.bounds.size.width

      # calculate left if width is relative, e.g 0.7
      if width > 0 && width <= 1
        max_width - (max_width * width) - right
      else
        max_width - width - right
      end
    end

    def computed_top
      height = computed_options[:height]
      top = computed_options[:top]
      bottom = computed_options[:bottom]
      return top if top
      return 0 if bottom.nil?

      height = 0.0 if height.nil?
      max_height = view.bounds.size.height

      # calculate top if height is relative, e.g 0.7
      if height > 0 && height <= 1
        max_height - (max_height * height) - bottom
      else
        max_height - height - bottom
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