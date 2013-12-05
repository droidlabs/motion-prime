module MotionPrime
  module DrawBackgroundMixin
    def draw_background_in(rect, options)
      bg_color = options[:background_color]
      border_width = options[:layer].try(:[], :border_width).to_f
      border_color = options[:layer].try(:[], :border_color) || bg_color || :black

      if bg_color || border_width > 0
        context = UIGraphicsGetCurrentContext()
        if bg_color
          CGContextSetFillColorWithColor(context, bg_color.uicolor.cgcolor)
          if border_width.zero?
            border_width = 1
            border_color = bg_color
          end
        end
        CGContextSetLineWidth(context, border_width) if border_width > 0
        CGContextSetStrokeColorWithColor(context, border_color.uicolor.cgcolor) if border_color

        if options[:layer] && radius = options[:layer][:corner_radius]
          bezierPath = UIBezierPath.bezierPathWithRoundedRect rect, cornerRadius: radius
          bezierPath.stroke
          bezierPath.fill
        else
          CGContextFillRect(context, rect)
          CGContextStrokeRect(context, rect)
        end
      end
    end
  end
end