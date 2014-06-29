motion_require '../draw.rb'
module MotionPrime
  class ViewDrawElement < DrawElement
    include DrawBackgroundMixin

    def draw_in(rect)
      super
      draw_in_context(UIGraphicsGetCurrentContext())
    end

    def draw_in_context(context)
      return if computed_options[:hidden]

      draw_background_in_context(context)
    end
  end
end