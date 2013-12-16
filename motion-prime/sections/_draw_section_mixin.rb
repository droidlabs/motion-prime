module MotionPrime
  module DrawSectionMixin
    include HasStyles
    include FrameCalculatorMixin
    attr_accessor :container_element, :container_gesture_recognizers

    def container_view
      container_element.try(:view)
    end

    def draw_in(rect)
      if @cached_draw_image
        context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, container_bounds, @cached_draw_image)
        render_image_elements
      else
        draw_background_in(rect)
        draw_elements(rect)
      end
    end

    def bind_gesture_on_container_for(element, action, receiver = nil)
      self.container_gesture_recognizers ||= begin
        set_container_gesture_recognizer
        []
      end
      self.container_gesture_recognizers << {element: element, action: action, receiver: receiver}
    end

    def prerender_elements
      scale = UIScreen.mainScreen.scale
      space = CGColorSpaceCreateDeviceRGB()
      bits_per_component = 8
      context = CGBitmapContextCreate(nil, container_bounds.size.width*scale, container_bounds.size.height*scale,
        bits_per_component, container_bounds.size.width*scale*4, space, KCGImageAlphaPremultipliedLast)

      CGContextScaleCTM(context, scale, scale)
      draw_background_in(container_bounds) # TODO: test this

      elements_to_draw.each do |key, element|
        element.draw_in_context(context)
      end
      @cached_draw_image = CGBitmapContextCreateImage(context)
    end

    private
      def set_container_gesture_recognizer
        single_tap = UITapGestureRecognizer.alloc.initWithTarget(self, action: 'on_container_tap_gesture:')
        single_tap.cancelsTouchesInView = false
        container_view.addGestureRecognizer single_tap
        container_view.setUserInteractionEnabled true
      end

      def on_container_tap_gesture(recognizer)
        target = Array.wrap(container_gesture_recognizers).detect do |gesture_data|
          CGRectContainsPoint(gesture_data[:element].computed_frame, recognizer.locationInView(container_view))
        end
        (target[:receiver] || self).send(target[:action], recognizer, target[:element]) if target
      end

      def draw_elements(rect)
        elements_to_draw.each do |key, element|
          element.draw_in(rect)
        end
      end

      def draw_background_in(rect)
        options = container_element.computed_options

        if gradient_options = options[:gradient]
          start_point = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))
          end_point = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))

          context = UIGraphicsGetCurrentContext()
          # CGContextSaveGState(context)
          CGContextAddRect(context, rect)
          CGContextClip(context)
          gradient = prepare_gradient(gradient_options)
          CGContextDrawLinearGradient(context, gradient, start_point, end_point, 0)
          # CGContextRestoreGState(context)
        elsif background_color = options[:background_color]
          unless background_color.uicolor == :clear.uicolor
            background_color.uicolor.setFill
            UIRectFill(rect)
          end
        end
      end

      def render_image_elements
        elements_to_draw.each do |key, element|
          element.load_image if element.is_a?(ImageDrawElement)
        end
      end
  end
end