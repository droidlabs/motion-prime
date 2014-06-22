motion_require '_section_with_container_mixin'
module MotionPrime
  module DrawSectionMixin
    extend ::MotionSupport::Concern

    include HasStyles
    include FrameCalculatorMixin
    include SectionWithContainerMixin

    attr_accessor :container_element, :container_gesture_recognizers, :cached_draw_image

    included do
      class_attribute :prerender_enabled
      container_element type: :view_with_section
    end

    def draw_in(rect, state = :normal)
      if cached_draw_image[state]
        context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, container_bounds, cached_draw_image[state])
        render_image_elements
      elsif prerender_enabled?
        prerender_elements_for_state(state)
        draw_in(rect, state) if cached_draw_image[state]
      else
        draw_background_in_context(UIGraphicsGetCurrentContext(), rect)
        draw_elements(rect)
      end
    end

    def before_element_render(element)
      return unless element == container_element
      self.container_gesture_recognizers = nil
      elements_to_draw.values.each(&:on_container_render)
    end

    def after_element_render(element); end

    def bind_gesture_on_container_for(element, action, receiver = nil)
      self.container_gesture_recognizers ||= begin
        set_container_gesture_recognizer
        []
      end
      self.container_gesture_recognizers << {element: element, action: action, receiver: receiver}
    end

    def clear_gesture_for_receiver(receiver)
      return unless self.container_gesture_recognizers
      self.container_gesture_recognizers.delete_if { |recognizer|
        !recognizer[:receiver].weakref_alive? || recognizer[:receiver] == receiver
      }
    end

    def prerender_elements_for_state(state = :normal)
      scale = UIScreen.mainScreen.scale
      space = CGColorSpaceCreateDeviceRGB()
      bits_per_component = 8
      context = CGBitmapContextCreate(nil, container_bounds.size.width*scale, container_bounds.size.height*scale,
        bits_per_component, container_bounds.size.width*scale*4, space, KCGImageAlphaPremultipliedLast)

      CGContextScaleCTM(context, scale, scale)

      draw_background_in_context(context, container_bounds)
      elements_to_draw.each do |key, element|
        element.draw_in_context(context)
      end

      cached_draw_image[state] = CGBitmapContextCreateImage(context)
    end

    def prerender_enabled?
      self.class.prerender_enabled
    end

    def cached_draw_image
      @cached_draw_image ||= MotionSupport::HashWithIndifferentAccess.new
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
          point = recognizer.locationInView(container_view)
          element = gesture_data[:element]
          section = element.section
          if section.has_container_bounds?
            point.x -= section.container_bounds.origin.x
            point.y -= section.container_bounds.origin.y
          end
          CGRectContainsPoint(element.computed_frame, point)
        end
        stop_propagation = false
        if target
          stop_propagation = !(target[:receiver] || self).send(target[:action], recognizer, target[:element])
        end
        recognizer.cancelsTouchesInView = stop_propagation
      end

      def draw_elements(rect)
        elements_to_draw.each do |key, element|
          element.draw_in(rect)
        end
      end

      def draw_background_in_context(context, rect)
        return unless container_element

        options = container_element.computed_options
        background_color = options[:background_color].try(:uicolor)

        if gradient_options = options[:gradient]
          if gradient_options[:type].to_s == 'horizontal'
            start_point = CGPointMake(0, 0.5)
            end_point = CGPointMake(1.0, 0.5)
          else
            start_point = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))
            end_point = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))
          end

          # CGContextSaveGState(context)
          CGContextAddRect(context, rect)
          CGContextClip(context)
          gradient = prepare_gradient(gradient_options)
          CGContextDrawLinearGradient(context, gradient, start_point, end_point, 0)
          # CGContextRestoreGState(context)
        elsif background_color && background_color != :clear.uicolor
          UIGraphicsPushContext(context)
          background_color.uicolor.setFill
          UIRectFill(rect)
          UIGraphicsPopContext()
        end
      end

      def render_image_elements
        elements_to_draw.each do |key, element|
          element.load_image if element.is_a?(ImageDrawElement)
        end
      end

    module ClassMethods
      def enable_prerender
        self.prerender_enabled = true
      end
    end
  end
end