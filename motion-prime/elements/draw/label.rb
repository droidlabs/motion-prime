motion_require '../draw.rb'
module MotionPrime
  class LabelDrawElement < DrawElement
    include ElementContentTextMixin
    include DrawBackgroundMixin

    def draw_options
      options = computed_options
      text = options[:text].to_s.gsub(/^[\n\r]+/, '')
      text_color = (options[:text_color] || :black).uicolor
      font = (options[:font] || :system).uifont

      text_alignment = (options.has_key?(:text_alignment) ? options[:text_alignment] : :left).uitextalignment
      line_break_mode = (options.has_key?(:line_break_mode) ? options[:line_break_mode] : :tail_truncation).uilinebreakmode

      top_left_corner = CGPointMake(computed_inner_left, computed_inner_top)
      if options[:number_of_lines].to_i.zero?
        inner_rect = CGRectMake(*top_left_corner.to_a, computed_width, computed_height)
      end
      super.merge({
        text: text,
        text_color: text_color,
        font: font,
        text_alignment: text_alignment,
        line_break_mode: line_break_mode,
        line_spacing: options[:line_spacing],
        underline: options[:underline],
        top_left_corner: top_left_corner,
        inner_rect: inner_rect
      })
    end

    def draw_in(rect)
      draw_in_context(UIGraphicsGetCurrentContext())
    end

    def draw_in_context(context)
      return if computed_options[:hidden]
      size_to_fit_if_needed
      set_text_position

      draw_background_in_context(context)

      UIGraphicsPushContext(context)
      options = draw_options
      if options[:line_spacing] || options[:underline]
        # attributed string
        paragrahStyle = NSMutableParagraphStyle.alloc.init

        paragrahStyle.setLineSpacing(options[:line_spacing]) if options[:line_spacing]
        paragrahStyle.setAlignment(options[:text_alignment])
        paragrahStyle.setLineBreakMode(options[:line_break_mode])
        attributes = {}
        attributes[NSParagraphStyleAttributeName] = paragrahStyle
        attributes[NSForegroundColorAttributeName] = options[:text_color]
        attributes[NSFontAttributeName] = options[:font]

        prepared_text = NSMutableAttributedString.alloc.initWithString(options[:text], attributes: attributes)
        if underline_range = options[:underline]
          # FIXME
          # prepared_text = NSMutableAttributedString.alloc.initWithAttributedString(prepared_text)
          # prepared_text.addAttributes({NSUnderlineStyleAttributeName => NSUnderlineStyleSingle}, range: underline_range)
        end

        if options[:inner_rect]
          prepared_text.drawInRect(options[:inner_rect])
        else
          prepared_text.drawAtPoint(options[:top_left_corner])
        end
      else
        # regular string
        prepared_text = options[:text]
        options[:text_color].set
        if options[:inner_rect]
          prepared_text.drawInRect(options[:inner_rect],
            withFont: options[:font],
            lineBreakMode: options[:line_break_mode],
            alignment: options[:text_alignment])
        else
          prepared_text.drawAtPoint(options[:top_left_corner], withFont: options[:font])
        end
      end
      UIGraphicsPopContext()
    end

    def default_padding_for(side)
      return super unless side.to_s == 'top'
      @padding_top || 0
    end

    def size_to_fit_if_needed
      if computed_options[:size_to_fit]
        computed_options[:width] ||= cached_content_outer_width
        computed_options[:height] ||= cached_content_outer_height
        reset_computed_values
        true
      end
    end

    def set_text_position
      if computed_options.slice(:padding_top, :padding_bottom, :padding).values.none?
        computed_options[:width] ||= computed_width
        @padding_top = (computed_outer_height - cached_content_height)/2
        # @padding_top += 1 unless @padding_top.zero?
      end
    end
  end
end