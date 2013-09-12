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

      if width.nil? && height.nil? && right.nil? && bottom.nil?
        options[:frame] = CGRectZero
      else
        frame = CGRectZero
        max_width = bounds.size.width
        max_height = bounds.size.height
        width = 0.0 if width.nil?
        height = 0.0 if height.nil?

        # calculate left and right if width is relative, e.g 0.7
        if width > 0 && width <= 1
          if right.nil?
            left ||= 0
            right = max_width - max_width * width
          else
            left = max_width - max_width * width
          end
        end

        # calculate top and bottom if height is relative, e.g 0.7
        if height > 0 && height <= 1
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
      return if value.nil?
      # ignore options
      return if key == 'size_to_fit' && view.is_a?(UILabel)
      return if (key == 'url' || key == 'default') && view.is_a?(UIImageView)

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
        color = value.uicolor
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
      elsif key.end_with?('image')
        view.setValue value.uiimage, forKey: key.camelize
      elsif key == 'keyboard_type'
        view.setKeyboardType value.uikeyboardtype
      elsif value.is_a?(Hash)
        self.class.new(view.send(key.camelize(:lower).to_sym), nil, value).apply
      else
        view.setValue value, forKey: key.camelize(:lower)
      end
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