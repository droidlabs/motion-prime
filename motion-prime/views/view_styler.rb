module MotionPrime
  class ViewStyler
    attr_reader :view, :options

    def initialize(view, bounds = CGRectZero, options = {})
      @options = Styles.extend_and_normalize_options options
      @view = view
      calculate_frame_for(bounds) if @options.delete(:calculate_frame)
    end

    def apply
      convert_primitives_to_objects(options)
      setValuesForKeysWithDictionary(options)
    end

    def convert_primitives_to_objects(options)
      options.each do |k,v|
        options[k] = STRUCTS_MAP[v.class].call(v) if STRUCTS_MAP.has_key?(v.class)
      end
    end

    def calculate_frame_for(bounds)
      width   = options.delete(:width)
      height  = options.delete(:height)
      top     = options.delete(:top)
      right   = options.delete(:right)
      bottom  = options.delete(:bottom)
      left    = options.delete(:left)
      value_type = options.delete(:value_type).to_s # absolute/relative

      if options[:height_to_fit].present? && height.nil? && (top.nil? || bottom.nil?)
        height = options[:height_to_fit]
      end

      if width.nil? && height.nil? && right.nil? && bottom.nil?
        options[:frame] = bounds
      else
        frame = CGRectZero
        max_width = bounds.size.width
        max_height = bounds.size.height
        width = 0.0 if width.nil?
        height = 0.0 if height.nil?

        # calculate left and right if width is relative, e.g 0.7
        if width && width > 0 && width <= 1 && value_type != 'absolute'
          if right.nil?
            left ||= 0
            right = max_width - max_width * width
          else
            left = max_width - max_width * width
          end
        end

        # calculate top and bottom if height is relative, e.g 0.7
        if height && height > 0 && height <= 1 && value_type != 'absolute'
          if bottom.nil?
            top ||= 0
            bottom = max_height - max_height * height
          else
            top = max_height - max_height * height
          end
        end

        mask = UIViewAutoresizingNone
        mask |= UIViewAutoresizingFlexibleTopMargin if top.nil?
        mask |= UIViewAutoresizingFlexibleLeftMargin if left.nil?
        mask |= UIViewAutoresizingFlexibleBottomMargin if bottom.nil?
        mask |= UIViewAutoresizingFlexibleRightMargin if right.nil?
        mask |= UIViewAutoresizingFlexibleWidth if !left.nil? && !right.nil?
        mask |= UIViewAutoresizingFlexibleHeight if !top.nil? && !bottom.nil?

        if !left.nil? && !right.nil?
          frame.origin.x = left
          frame.size.width = max_width - left - right
        elsif !right.nil?
          frame.origin.x = max_width - width - right
          frame.size.width = width
        elsif !left.nil?
          frame.origin.x = left
          frame.size.width = width
        else
          frame.origin.x = max_width / 2 - width / 2
          frame.size.width = width
        end

        if !top.nil? && !bottom.nil?
          frame.origin.y = top
          frame.size.height = max_height - top - bottom
        elsif !bottom.nil?
          frame.origin.y = max_height - height - bottom
          frame.size.height = height
        elsif !top.nil?
          frame.origin.y = top
          frame.size.height = height
        else
          frame.origin.y = max_height / 2 - height / 2
          frame.size.height = height
        end

        options[:frame] = frame
        options[:autoresizingMask] = mask
      end
    end

    def setValue(value, forUndefinedKey: key)
      # return if value.nil?
      # ignore options
      return if key == 'size_to_fit' && view.is_a?(UILabel)
      return if (key == 'url' || key == 'default') && view.is_a?(UIImageView)
      return if %w[max_width min_width height_to_fit container].include? key.to_s

      # apply options
      if key.end_with?('title_color')
        view.setTitleColor value.uicolor, forState: UIControlStateNormal
      elsif key.end_with?('alignment') && value.is_a?(Symbol)
        view.setValue value.uitextalignment, forKey: key.camelize
      elsif key.end_with?('line_break_mode') && value.is_a?(Symbol)
        view.setValue value.uilinebreakmode, forKey: key.camelize
      elsif key.end_with?('title_shadow_color')
        view.setTitleShadowColor value.uicolor, forState: UIControlStateNormal
      elsif key.end_with?('color')
        color = value.try(:uicolor)
        color = color.cgcolor if view.is_a?(CALayer)
        view.send :"#{key.camelize(:lower)}=", color
      elsif key.end_with?('background_image')
        if view.is_a?(UIButton)
          view.setBackgroundImage value.uiimage, forState: UIControlStateNormal
        elsif view.is_a?(UISearchBar) && key == 'search_field_background_image'
          view.setSearchFieldBackgroundImage value.uiimage, forState: UIControlStateNormal
        else
          view.setBackgroundColor value.uiimage.uicolor
        end
      elsif key.end_with?('background_view')
        if view.is_a?(UITableView)
          bg_view = UIView.alloc.initWithFrame(view.bounds)
          bg_view.backgroundColor = value[:color].uicolor
          view.backgroundView = bg_view
        else
          view.setValue value, forKey: key.camelize(:lower)
        end
      elsif key.end_with?('image')
        view.setValue value.uiimage, forKey: key.camelize
      elsif key.end_with?('_content_offset')
        current_inset = view.contentInset
        current_inset.send("#{key.partition('_').first}=", value)
        view.contentInset = current_inset
      elsif key == 'autocapitalization'
        view.autocapitalizationType = UITextAutocapitalizationTypeNone if value === false
      elsif key == 'keyboard_type'
        view.setKeyboardType value.uikeyboardtype
      elsif key == 'mask'
        radius = value[:radius]
        bounds = CGRectMake(0, 0, value[:width], value[:height])
        mask_path = UIBezierPath.bezierPathWithRoundedRect(bounds, byRoundingCorners: UIRectCornerAllCorners, cornerRadii: CGSizeMake(radius, radius))
        mask_layer = CAShapeLayer.layer
        mask_layer.frame = bounds
        mask_layer.path = mask_path.CGPath
        view.layer.mask = mask_layer
      elsif key == 'attributed_text_options'
        paragrahStyle = NSMutableParagraphStyle.alloc.init
        paragrahStyle.setLineSpacing(value[:line_spacing])
        attributedString = NSAttributedString.alloc.initWithString(value[:text], attributes:{NSParagraphStyleAttributeName => paragrahStyle})
        view.attributedText = attributedString
      elsif value.is_a?(Hash)
        self.class.new(view.send(key.camelize(:lower).to_sym), nil, value).apply
      else
        view.setValue value, forKey: key.camelize(:lower)
      end
    rescue => e
      puts "Error: Can't set `#{key}`: `#{value}` for #{view.to_s}"
    end

    STRUCTS_MAP = {
      CGAffineTransform   => Proc.new {|v| NSValue.valueWithCGAffineTransform(v) },
      CGPoint             => Proc.new {|v| NSValue.valueWithCGPoint(v) },
      CGRect              => Proc.new {|v| NSValue.valueWithCGRect(v) },
      CGSize              => Proc.new {|v| NSValue.valueWithCGSize(v) },
      UIEdgeInsets        => Proc.new {|v| NSValue.valueWithUIEdgeInsets(v) },
      UIOffset            => Proc.new {|v| NSValue.valueWithUIOffset(v) }
    }
  end
end