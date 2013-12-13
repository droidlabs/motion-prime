motion_require '../draw.rb'
module MotionPrime
  class LabelDrawElement < DrawElement
    include ElementContentTextMixin
    include DrawBackgroundMixin

    def default_padding_for(side)
      return super unless side.to_s == 'top'
      @padding_top || 0
    end

    def draw_in(rect)
      size_to_fit_if_needed or set_text_position
      options = computed_options

      return if computed_options[:hidden]

      # render background and border
      background_rect = CGRectMake(computed_left, computed_top, computed_outer_width, computed_outer_height)
      draw_background_in(background_rect, options)

      # render text
      color = (options[:text_color] || :black).uicolor
      font = (options[:font] || :system).uifont
      alignment = (options.has_key?(:text_alignment) ? options[:text_alignment] : :left).uitextalignment
      line_break_mode = (options.has_key?(:line_break_mode) ? options[:line_break_mode] : :tail_truncation).uilinebreakmode
      label_text = options[:text].to_s.gsub(/^[\n\r]+/, '')

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

        label_text = NSMutableAttributedString.alloc.initWithString(label_text, attributes: attributes)
        if underline_range = options[:underline]
          # FIXME
          # label_text = NSMutableAttributedString.alloc.initWithAttributedString(label_text)
          # label_text.addAttributes({NSUnderlineStyleAttributeName => NSUnderlineStyleSingle}, range: underline_range)
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
        computed_options[:width] ||= cached_content_outer_width
        if computed_options[:width]
          computed_options[:height] ||= cached_content_outer_height
        end
        reset_computed_values
        true
      end
    end

    def set_text_position
      if computed_options.slice(:padding_top, :padding_bottom, :padding).none?
        computed_options[:width] ||= computed_width
        @padding_top = (computed_outer_height - cached_content_height)/2
        # @padding_top += 1 unless @padding_top.zero?
      end
    end
  end
end