motion_require '../draw.rb'
module MotionPrime
  class LabelDrawElement < DrawElement
    include MotionPrime::ElementTextDimensionsMixin
    include MotionPrime::ElementContentPaddingMixin

    def draw_in(rect)
      options = computed_options
      return if options[:hidden]

      size_to_fit_if_needed

      # render background
      bg_color = options[:background_color]
      if bg_color
        rect = CGRectMake(
          computed_left, computed_top, computed_width, computed_height
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
      color = (options[:text_color] || :black).uicolor
      font = (options[:font] || :system).uifont
      alignment = (options.has_key?(:text_alignment) ? options[:text_alignment] : :left).uitextalignment
      line_break_mode = (options.has_key?(:line_break_mode) ? options[:line_break_mode] : :wordwrap).uilinebreakmode
      label_text = options[:text].to_s

      top_left_corner = CGPointMake(computed_inner_left, computed_inner_top)
      if options[:number_of_lines].to_i.zero?
        rect = CGRectMake(*top_left_corner.to_a, computed_width, computed_height)
      end

      if options[:line_spacing] || options[:underline]
        # attributed string
        paragrahStyle = NSMutableParagraphStyle.alloc.init

        paragrahStyle.setLineSpacing(options[:line_spacing]) if options[:line_spacing]
        paragrahStyle.setAlignment(alignment)
        paragrahStyle.setLineBreakMode(line_break_mode)
        attributes = {}
        attributes[NSParagraphStyleAttributeName] = paragrahStyle
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font

        label_text = NSAttributedString.alloc.initWithString(label_text, attributes: attributes)
        if underline_range = options[:underline]
          label_text = NSMutableAttributedString.alloc.initWithAttributedString(label_text)
          label_text.addAttributes({NSUnderlineStyleAttributeName => NSUnderlineStyleSingle}, range: underline_range)
        end

        rect ? label_text.drawInRect(rect) : label_text.drawAtPoint(top_left_corner)
      else
        # regular string
        color.set
        if rect
          label_text.drawInRect(rect,
            withFont: font,
            lineBreakMode: line_break_mode,
            alignment: alignment)
        else
          label_text.drawAtPoint(top_left_corner, withFont: font)
        end
      end
    end

    def size_to_fit_if_needed
      if computed_options[:size_to_fit]
        @computed_options[:width] ||= content_outer_width
        if computed_options[:width]
          @computed_options[:height] = content_outer_height
        end
        reset_computed_values
      end
    end

    def default_padding_for(side)
      0
    end
  end
end