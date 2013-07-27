motion_require '../draw.rb'
module MotionPrime
  class LabelDrawElement < DrawElement
    include MotionPrime::ElementTextHeightMixin

    def draw_in(rect)
      options = computed_options
      return if options[:hidden]
      color = options[:text_color]
      color.uicolor.set if color
      if options[:number_of_lines] != 0
        options[:text].to_s.drawAtPoint(
          CGPointMake(computed_left, computed_top),
          withFont: options[:font].uifont
        )
      else
        rect = CGRectMake(
          computed_left, computed_top, computed_width, computed_height
        )
        line_break = options.has_key?(:line_break_mode) ? options[:line_break_mode] : :wordwrap
        alignment = options.has_key?(:text_alignment) ? options[:text_alignment] : :left
        options[:text].to_s.drawInRect(
          rect, withFont: options[:font].uifont,
          lineBreakMode: line_break.uilinebreakmode,
          alignment: alignment.uitextalignment
        )
      end
    end
  end
end