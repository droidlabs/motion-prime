motion_require '../draw.rb'
module MotionPrime
  class ViewDrawElement < DrawElement
    include DrawBackgroundMixin

    def draw_in(rect)
      draw_in_context(UIGraphicsGetCurrentContext())
    end

    def draw_in_context(context)
      return if options[:hidden]

      draw_background_in_context(context)
    end
  end
end