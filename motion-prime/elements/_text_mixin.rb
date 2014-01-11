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
      styles << "line-height: #{options.fetch(:line_height, options[:line_spacing].to_f + options[:font].pointSize)}px;"
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
      paragrahStyle = NSMutableParagraphStyle.alloc.init

      if options[:line_height]
        paragrahStyle.setMinimumLineHeight(options[:line_height])
      elsif options[:line_spacing]
        paragrahStyle.setLineSpacing(options[:line_spacing])
      end
      paragrahStyle.setAlignment(options[:text_alignment]) if options[:text_alignment]
      paragrahStyle.setLineBreakMode(options[:line_break_mode]) if options[:line_break_mode]
      attributes = {}
      attributes[NSParagraphStyleAttributeName] = paragrahStyle
      attributes[NSForegroundColorAttributeName] = options[:text_color]
      attributes[NSFontAttributeName] = options[:font]

      prepared_text = NSMutableAttributedString.alloc.initWithString(options[:text] || '', attributes: attributes)
      if underline_range = options[:underline]
        # FIXME
        # prepared_text = NSMutableAttributedString.alloc.initWithAttributedString(prepared_text)
        # prepared_text.addAttributes({NSUnderlineStyleAttributeName => NSUnderlineStyleSingle}, range: underline_range)
      end
      prepared_text
    end
  end
end