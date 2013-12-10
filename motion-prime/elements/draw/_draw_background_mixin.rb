module MotionPrime
  module DrawBackgroundMixin
    def draw_background_in(draw_rect, options)

      bg_color = options[:background_color]
      border_radius = options[:layer].try(:[], :corner_radius)
      border_width = options[:layer].try(:[], :border_width).to_f
      border_color = options[:layer].try(:[], :border_color) || bg_color || :black

      rect = CGRectInset(draw_rect, -(border_width - 1)*0.5, -(border_width - 1)*0.5)

      if bg_color || border_width > 0
        if border_radius
          bezierPath = UIBezierPath.bezierPathWithRoundedRect rect, cornerRadius: border_radius
          if border_width > 0
            bezierPath.lineWidth = border_width
            border_color.uicolor.setStroke
            bezierPath.stroke
          end
          if bg_color
            bg_color.uicolor.setFill
            bezierPath.fill
          end
        else
          context = UIGraphicsGetCurrentContext()
          if border_width > 0 && border_color
            CGContextSetLineWidth(context, border_width)
            CGContextSetStrokeColorWithColor(context, border_color.uicolor.cgcolor)
            CGContextStrokeRect(context, rect)
          end
          CGContextSetFillColorWithColor(context, bg_color.uicolor.cgcolor) if bg_color
          CGContextFillRect(context, rect) if bg_color
        end
      end
    end
  end
end