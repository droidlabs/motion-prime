module MotionPrime
  module DrawMixin
    include HasStyles
    attr_accessor :container_element, :container_gesture_recognizers

    def container_view
      container_element.try(:view)
    end

    def draw_in(rect)
      draw_background(rect)
      draw_elements(rect)
    end

    def bind_gesture_on_container_for(element, action, receiver = nil)
      self.container_gesture_recognizers ||= begin
        set_container_gesture_recognizer
        []
      end
      self.container_gesture_recognizers << {element: element, action: action, receiver: receiver}
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

      def view_style_options
        @view_style_options ||= begin
          options = Styles.for(container_options[:styles])
          normalize_options(options)
          options
        end
      end

      def draw_background(rect)
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
  end
end