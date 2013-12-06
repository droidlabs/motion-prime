module MotionPrime
  module DrawBackgroundMixin
    def draw_background_in(rect, options)
      bg_color = options[:background_color]
      border_radius = options[:layer].try(:[], :corner_radius)
      border_width = options[:layer].try(:[], :border_width).to_f
      border_color = options[:layer].try(:[], :border_color) || bg_color || :black

      if bg_color || border_width > 0
        context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, bg_color.uicolor.cgcolor) if bg_color
        CGContextSetLineWidth(context, border_width) if border_width > 0
        CGContextSetStrokeColorWithColor(context, border_color.uicolor.cgcolor) if border_color

        if border_radius
          bezierPath = UIBezierPath.bezierPathWithRoundedRect rect, cornerRadius: border_radius
          bezierPath.stroke if border_width > 0
          bezierPath.fill if bg_color
        else
          CGContextStrokeRect(context, rect) if border_width > 0
          CGContextFillRect(context, rect) if bg_color
        end
      end
    end
  end
end