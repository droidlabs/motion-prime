module MotionPrime
  module ElementTextMixin
    # Options
    # text
    # text_color
    # font
    # line_spacing
    # text_alignment
    # text_alignment_name
    # line_break_mode
    # underline (range)

    def html_string(options)
      styles = []
      styles << "color: #{options[:text_color].hex};" if options[:text_color]
      styles << "line-height: #{options[:line_height] || (options[:line_spacing].to_f + options[:font].pointSize)}px;"
      styles << "font-family: '#{options[:font].familyName}';"
      styles << "font-size: #{options[:font].pointSize}px;"
      styles << "text-align: #{options[:text_alignment_name]};" if options[:text_alignment_name]

      html_options = {
        NSDocumentTypeDocumentAttribute => NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute => NSNumber.numberWithInt(NSUTF8StringEncoding)
      }
      # DTCoreTextFontDescriptor.setOverrideFontName(Prime::Config.font.light, forFontFamily: 'Calibri', bold: false, italic: false)
      # DTCoreTextFontDescriptor.setOverrideFontName(Prime::Config.font.bold, forFontFamily: 'Calibri', bold: true, italic: false)
      # DTCoreTextFontDescriptor.setOverrideFontName(Prime::Config.font.light_italic, forFontFamily: 'Calibri', bold: false, italic: true)
      # DTCoreTextFontDescriptor.setOverrideFontName(Prime::Config.font.bold_italic, forFontFamily: 'Calibri', bold: true, italic: true)

      text = "#{options[:text]}<style>* { #{styles.join} }</style>"
      NSAttributedString.alloc.initWithData(text.dataUsingEncoding(NSUTF8StringEncoding), options: html_options, documentAttributes: nil, error: nil)
    end

    def attributed_string(options)
      attributes = {}
      line_height = options[:line_height]
      line_spacing = options[:line_spacing]
      text_alignment = options[:text_alignment]
      line_break_mode = options[:line_break_mode]

      if line_height || line_spacing || text_alignment || line_break_mode
        paragrah_style = NSMutableParagraphStyle.alloc.init
        if line_height
          paragrah_style.setMinimumLineHeight(line_height)
        elsif line_spacing
          paragrah_style.setLineSpacing(line_spacing)
        end
        if text_alignment
          text_alignment = text_alignment.uitextalignment if text_alignment.is_a?(Symbol)
          paragrah_style.setAlignment(text_alignment)
        end
        if line_break_mode
          line_break_mode = line_break_mode.uilinebreakmode if line_break_mode.is_a?(Symbol)
          paragrah_style.setLineBreakMode(line_break_mode)
        end
        attributes[NSParagraphStyleAttributeName] = paragrah_style
      end

      attributes[NSForegroundColorAttributeName] = options[:text_color].uicolor if options[:text_color]
      attributes[NSFontAttributeName] = options[:font].uifont if options[:font]

      prepared_text = NSMutableAttributedString.alloc.initWithString(options[:text].to_s, attributes: attributes)
      underline_range = options[:underline]
      fragment_color = options[:fragment_color]
      if paragrah_style && (underline_range || fragment_color) && options.fetch(:number_of_lines, 1) == 1
        Prime.logger.debug "If attributed text has paragraph style and underline - you must set number of lines != 1"
      end

      if underline_range
        underline_range = [0, options[:text].length] if underline_range === true
        prepared_text.addAttributes({NSUnderlineStyleAttributeName => NSUnderlineStyleSingle}, range: underline_range)
      end
      if fragment_color
        prepared_text.addAttributes({NSForegroundColorAttributeName => fragment_color[:color].uicolor}, range: fragment_color[:range])
      end
      prepared_text
    end
  end
end