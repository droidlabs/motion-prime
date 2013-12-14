module MotionPrime
  class ViewStyler
    include FrameCalculatorMixin
    include HasStyles
    include HasClassFactory

    attr_reader :view, :options

    def initialize(view, bounds = CGRectZero, options = {})
      @options = Styles.extend_and_normalize_options options
      @view = view
      prepare_frame_for(bounds) if @options.delete(:calculate_frame)
    end

    def apply
      options.each do |key, value|
        set_option(key.to_s, value)
      end
    end

    def prepare_frame_for(bounds)
      frame = calculate_frome_for(bounds, options)
      if STRUCTS_MAP.has_key?(frame.class)
        options[:frame] = STRUCTS_MAP[frame.class].call(frame)
      end

      if options.slice(:width, :height, :right, :bottom, :height_to_fit).values.any?
        mask = UIViewAutoresizingNone
        mask |= UIViewAutoresizingFlexibleTopMargin if options[:top].nil?
        mask |= UIViewAutoresizingFlexibleLeftMargin if options[:left].nil?
        mask |= UIViewAutoresizingFlexibleBottomMargin if options[:bottom].nil?
        mask |= UIViewAutoresizingFlexibleRightMargin if options[:right].nil?
        mask |= UIViewAutoresizingFlexibleWidth if !options[:left].nil? && !options[:right].nil?
        mask |= UIViewAutoresizingFlexibleHeight if !options[:top].nil? && !options[:bottom].nil?
        options[:autoresizingMask] = mask
      end
    end

    def set_option(key, value)
      # return if value.nil?
      # ignore options
      return if key == 'section' && !view.respond_to?(:section=)
      return if key == 'size_to_fit' && view.is_a?(UILabel)
      return if (key == 'url' || key == 'default') && view.is_a?(UIImageView)
      return if %w[
        styles has_drawn_content
        width height top right bottom left value_type
        max_width max_outer_width min_width min_outer_width
        max_height max_outer_height min_height min_outer_width
        height_to_fit container parent_frame].include? key.to_s

      # apply options
      if key.end_with?('title_color')
        view.setTitleColor value.uicolor, forState: UIControlStateNormal
      elsif key.end_with?('alignment') && value.is_a?(Symbol)
        view.setValue value.uitextalignment, forKey: camelize_factory(key)
      elsif key.end_with?('line_break_mode') && value.is_a?(Symbol)
        view.setValue value.uilinebreakmode, forKey: camelize_factory(key)
      elsif key.end_with?('title_shadow_color')
        view.setTitleShadowColor value.uicolor, forState: UIControlStateNormal
      elsif key.end_with?('color')
        color = value.try(:uicolor)
        color = color.cgcolor if view.is_a?(CALayer)
        view.send :"#{low_camelize_factory(key)}=", color
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
          view.setValue value, forKey: low_camelize_factory(key)
        end
      elsif key.end_with?('image')
        view.setValue value.uiimage, forKey: camelize_factory(key)
      elsif key.end_with?('_content_inset')
        current_inset = view.contentInset
        current_inset.send("#{key.partition('_').first}=", value)
        view.contentInset = current_inset
      elsif key == 'autocapitalization'
        view.autocapitalizationType = UITextAutocapitalizationTypeNone if value === false
      elsif key == 'keyboard_type'
        view.setKeyboardType value.uikeyboardtype
      elsif key == 'rounded_corners'
        radius = value[:radius].to_f
        corner_consts = {top_left: UIRectCornerTopLeft, bottom_left: UIRectCornerBottomLeft, bottom_right: UIRectCornerBottomRight, top_right: UIRectCornerTopRight}
        corners = value[:corners].inject(0) { |result, corner| result|corner_consts[corner] }
        size = options[:parent_frame].size
        bounds = CGRectMake(0, 0, size.width, size.height)
        mask_path = UIBezierPath.bezierPathWithRoundedRect(bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(radius, radius))
        mask_layer = CAShapeLayer.layer
        mask_layer.frame = bounds
        mask_layer.path = mask_path.CGPath
        view.mask = mask_layer
      elsif key == 'mask'
        radius = value[:radius]
        bounds = CGRectMake(0, 0, value[:width], value[:height])
        mask_path = UIBezierPath.bezierPathWithRoundedRect(bounds, byRoundingCorners: UIRectCornerAllCorners, cornerRadii: CGSizeMake(radius, radius))
        mask_layer = CAShapeLayer.layer
        mask_layer.frame = bounds
        mask_layer.path = mask_path.CGPath
        view.layer.mask = mask_layer
      elsif key == 'attributed_text_options'
        attributes = {}
        if line_spacing = value[:line_spacing]
          paragrahStyle = NSMutableParagraphStyle.alloc.init
          paragrahStyle.setLineSpacing(line_spacing)
          attributes[NSParagraphStyleAttributeName] = paragrahStyle
        end

        attributedString = NSAttributedString.alloc.initWithString(value[:text], attributes: attributes)
        if underline_range = value[:underline]
          attributedString = NSMutableAttributedString.alloc.initWithAttributedString(attributedString)
          attributedString.addAttributes({NSUnderlineStyleAttributeName => NSUnderlineStyleSingle}, range: underline_range)
        end
        if fragment_color = value[:fragment_color]
          attributedString = NSMutableAttributedString.alloc.initWithAttributedString(attributedString)
          attributedString.addAttributes({NSForegroundColorAttributeName => fragment_color[:color].uicolor}, range: fragment_color[:range])
        end
        if view.is_a?(UIButton)
          view.setAttributedTitle attributedString, forState: UIControlStateNormal
        else
          view.attributedText = attributedString
        end
      elsif key == 'gradient'
        gradient = prepare_gradient(value)
        view.layer.insertSublayer(gradient, atIndex: 0)
      elsif key == 'selection_style' && view.is_a?(UITableViewCell) && value.is_a?(Symbol)
        view.setSelectionStyle value.uitablecellselectionstyle
      elsif key == 'separator_inset' && (view.is_a?(UITableViewCell) || view.is_a?(UITableView))
        if value.to_s == 'none'
          view.separatorInset = UIEdgeInsetsMake(0, 320, 0, 0)
        elsif value.is_a?(Array) && value.count == 2
          view.separatorInset = UIEdgeInsetsMake(0, value.first, 0, value.last)
        end
      elsif value.is_a?(Hash)
        self.class.new(view.send(low_camelize_factory(key).to_sym), nil, value.merge(parent_frame: options[:frame] || options[:parent_frame])).apply
      else
        view.setValue value, forKey: low_camelize_factory(key)
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