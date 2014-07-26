module MotionPrime
  module DrawBackgroundMixin
    def draw_background_in_context(context = nil)
      context ||= UIGraphicsGetCurrentContext()
      options = draw_options
      rect, background_color, border_width, border_color, border_sides, corner_radius, dashes_array, rounded_corners = options.slice(:rect, :background_color, :border_width, :border_color, :border_sides, :corner_radius, :dashes, :rounded_corners).values

      return unless background_color || border_width > 0

      inset = border_width > 0 ? (border_width - 1 )*0.5 : 0
      rect = CGRectInset(rect, -inset, -inset)

      if dashes_array
        dashes = Pointer.new(:float, dashes_array.count)
        dashes_array.each_with_index { |length, i| dashes[i] = length }
      end

      if corner_radius > 0 && !rounded_corners
        bezier_path = UIBezierPath.bezierPathWithRoundedRect rect, cornerRadius: corner_radius
        UIGraphicsPushContext(context)
        bezier_path.setLineDash(dashes, count: dashes_array.count, phase: 0) if dashes
        if border_width > 0
          bezier_path.lineWidth = border_width
          border_color.setStroke
          bezier_path.stroke
        end
        if background_color
          background_color.setFill
          bezier_path.fill
        end
        UIGraphicsPopContext()
      elsif corner_radius > 0
        CGContextSetLineDash(context, dashes_array.count, dashes, 0) if dashes
        CGContextSetLineWidth(context, border_width) if border_width > 0
        CGContextSetStrokeColorWithColor(context, border_color.uicolor.cgcolor) if border_color
        draw_rect_in_context(context, rect: rect, radius: corner_radius, rounded_corners: rounded_corners)
        CGContextSaveGState(context)
        CGContextClip(context)
        if background_color
          CGContextSetFillColorWithColor(context, background_color.uicolor.cgcolor)
          CGContextFillRect(context, rect)
        end
        CGContextRestoreGState(context)
      else
        if border_width > 0 && border_color
          CGContextSetLineDash(context, dashes_array.count, dashes, 0) if dashes
          CGContextSetLineWidth(context, border_width)
          CGContextSetStrokeColorWithColor(context, border_color.uicolor.cgcolor)

          if border_sides.present?
            points = [
              [rect.origin.x, rect.origin.y],
              [rect.origin.x + rect.size.width, rect.origin.y],
              [rect.origin.x + rect.size.width, rect.origin.y + rect.size.height],
              [rect.origin.x, rect.origin.y + rect.size.height]
            ]
            CGContextMoveToPoint(context, *points[0])
            if border_sides.include?(:top)
              CGContextAddLineToPoint(context, *points[1])
            else
              CGContextMoveToPoint(context, *points[1])
            end
            if border_sides.include?(:right)
              CGContextAddLineToPoint(context, *points[2])
            else
              CGContextMoveToPoint(context, *points[2])
            end
            if border_sides.include?(:bottom)
              CGContextAddLineToPoint(context, *points[3])
            else
              CGContextMoveToPoint(context, *points[3])
            end
            if border_sides.include?(:left)
              CGContextAddLineToPoint(context, *points[0])
            else
              CGContextMoveToPoint(context, *points[0])
            end
            CGContextStrokePath(context)
          else
            CGContextStrokeRect(context, rect)
          end
        end

        if background_color
          CGContextSetFillColorWithColor(context, background_color.uicolor.cgcolor)
          CGContextFillRect(context, rect)
        end
      end
    end

    def draw_rect_in_context(context, options)
      rect = options.fetch(:rect)
      radius = options.fetch(:radius, 0)
      rounded_corners = options[:rounded_corners] || [:top_left, :top_right, :bottom_right, :bottom_left]

      CGContextBeginPath(context)

      x_left = rect.origin.x
      x_left_center = x_left + radius
      x_right_center = x_left + rect.size.width - radius
      x_right = x_left + rect.size.width
      y_top = rect.origin.y
      y_top_center = y_top + radius
      y_bottom_center = y_top + rect.size.height - radius
      y_bottom = y_top + rect.size.height
      CGContextMoveToPoint(context, x_left, y_top_center)

      if rounded_corners.include?(:top_left)
        CGContextAddArcToPoint(context, x_left, y_top, x_left_center, y_top, radius)
      else
        CGContextAddLineToPoint(context, x_left, y_top)
      end
      CGContextAddLineToPoint(context, x_right_center, y_top)

      if rounded_corners.include?(:top_right)
        CGContextAddArcToPoint(context, x_right, y_top, x_right, y_top_center, radius)
      else
        CGContextAddLineToPoint(context, x_right, y_top)
      end
      CGContextAddLineToPoint(context, x_right, y_bottom_center)

      if rounded_corners.include?(:bottom_right)
        CGContextAddArcToPoint(context, x_right, y_bottom, x_right_center, y_bottom, radius)
      else
        CGContextAddLineToPoint(context, x_right, y_bottom)
      end
      CGContextAddLineToPoint(context, x_left_center, y_bottom)

      if rounded_corners.include?(:bottom_left)
        CGContextAddArcToPoint(context, x_left, y_bottom, x_left, y_bottom_center, radius)
      else
        CGContextAddLineToPoint(context, x_left, y_bottom)
      end
      CGContextAddLineToPoint(context, x_left, y_top_center)

      CGContextClosePath(context)
    end
  end
end