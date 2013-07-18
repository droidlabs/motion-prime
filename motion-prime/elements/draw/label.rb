motion_require '../draw.rb'
module MotionPrime
  class LabelDrawElement < DrawElement
    def draw_in(rect)
      color = computed_options[:color] || computed_options[:text_color]
      color.uicolor.set if color
      computed_options[:text].to_s.drawAtPoint(
        CGPointMake(computed_left, computed_top),
        withFont: computed_options[:font]
      )
    end
  end
end