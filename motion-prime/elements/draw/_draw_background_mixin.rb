module MotionPrime
  module DrawBackgroundMixin
    def draw_background_in_context(context = nil)
      context ||= UIGraphicsGetCurrentContext()
      options = draw_options
      rect, background_color, border_width, border_color, corner_radius = options.slice(:rect, :background_color, :border_width, :border_color, :corner_radius).values

      return unless background_color || border_width > 0

      inset = border_width > 0 ? (border_width - 1 )*0.5 : 0
      rect = CGRectInset(rect, -inset, -inset)
      if corner_radius > 0
        bezierPath = UIBezierPath.bezierPathWithRoundedRect rect, cornerRadius: corner_radius
        UIGraphicsPushContext(context)
        if border_width > 0
          bezierPath.lineWidth = border_width
          border_color.setStroke
          bezierPath.stroke
        end
        if background_color
          background_color.setFill
          bezierPath.fill
        end
        UIGraphicsPopContext()
      else
        if border_width > 0 && border_color
          CGContextSetLineWidth(context, border_width)
          CGContextSetStrokeColorWithColor(context, border_color.uicolor.cgcolor)
          CGContextStrokeRect(context, rect)
        end
        CGContextSetFillColorWithColor(context, background_color.uicolor.cgcolor) if background_color
        CGContextFillRect(context, rect) if background_color
      end
    end
  end
end