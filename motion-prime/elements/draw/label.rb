motion_require '../draw.rb'
module MotionPrime
  class LabelDrawElement < DrawElement
    include MotionPrime::ElementTextDimensionsMixin

    def draw_in(rect)
      options = computed_options
      return if options[:hidden]

      size_to_fit_if_needed

      # render background
      bg_color = options[:background_color]
      if bg_color
        rect = CGRectMake(
          computed_left, computed_top, computed_outer_width, computed_outer_height
        )

        if computed_options[:layer] && radius = options[:layer][:corner_radius]
          bezierPath = UIBezierPath.bezierPathWithRoundedRect rect, cornerRadius: radius
          context = UIGraphicsGetCurrentContext()
          CGContextSetStrokeColorWithColor(context, bg_color.uicolor.cgcolor)
          CGContextSetFillColorWithColor(context, bg_color.uicolor.cgcolor)
          bezierPath.stroke
          bezierPath.fill
        else
          bg_color.uicolor.setFill
          UIRectFill(rect)
        end
      end

      # render text
      color = options[:text_color] || :black
      color.uicolor.set
      font = options[:font] || :system
      if options[:number_of_lines] != 0
        options[:text].to_s.drawAtPoint(
          CGPointMake(computed_inner_left, computed_inner_top),
          withFont: font.uifont
        )
      else
        rect = CGRectMake(
          computed_inner_left, computed_inner_top,
          computed_width, computed_height
        )
        line_break = options.has_key?(:line_break_mode) ? options[:line_break_mode] : :wordwrap
        alignment = options.has_key?(:text_alignment) ? options[:text_alignment] : :left
        options[:text].to_s.drawInRect(
          rect, withFont: font.uifont,
          lineBreakMode: line_break.uilinebreakmode,
          alignment: alignment.uitextalignment
        )
      end
    end

    def size_to_fit_if_needed
      if computed_options[:size_to_fit]
        @computed_options[:width] = content_width
        if computed_options[:width]
          @computed_options[:height] = content_height
        end
        reset_computed_values
      end
    end
  end
end