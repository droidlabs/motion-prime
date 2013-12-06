motion_require '../draw.rb'
module MotionPrime
  class ViewDrawElement < DrawElement
    include DrawBackgroundMixin

    def draw_in(rect)
      return if computed_options[:hidden]
      options = computed_options

      background_rect = CGRectMake(computed_left, computed_top, computed_outer_width, computed_outer_height)
      draw_background_in(background_rect, options)
    end
  end
end