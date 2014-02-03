module MotionPrime
  class ViewStyler
    include FrameCalculatorMixin
    include HasStyles
    include HasClassFactory
    include ElementTextMixin

    attr_reader :view, :options

    def initialize(view, bounds = CGRectZero, options = {})
      @options = Styles.extend_and_normalize_options options
      @view = view
      prepare_frame_for(bounds) if @options.delete(:calculate_frame)
      prepare_options!
    end

    def apply
      converted_options = convert_primitives_to_objects(options)
      converted_options.each do |key, value|
        set_option(key.to_s, value)
      end
    end

    def convert_primitives_to_objects(options)
      options.inject({}) do |result, (k, v)|
        v = STRUCTS_MAP[v.class].call(v) if STRUCTS_MAP.has_key?(v.class)
        result[k] = v
        result
      end
    end

    def prepare_frame_for(bounds)
      options[:frame] = calculate_frome_for(bounds, options.merge(test: view.is_a?(UITextView)))
      if options.slice(:width, :height, :right, :bottom, :height_to_fit).values.any?
        mask = UIViewAutoresizingNone
        mask |= UIViewAutoresizingFlexibleTopMargin if options[:top].nil?
        mask |= UIViewAutoresizingFlexibleLeftMargin if options[:left].nil?
        mask |= UIViewAutoresizingFlexibleBottomMargin if options[:bottom].nil?
        mask |= UIViewAutoresizingFlexibleRightMargin if options[:right].nil?
        mask |= UIViewAutoresizingFlexibleWidth if !options[:left].nil? && !options[:right].nil?
        mask |= UIViewAutoresizingFlexibleHeight if options[:height_to_fit].nil? && (!options[:top].nil? && !options[:bottom].nil?)
        options[:autoresizingMask] = mask
      end
    end

    def prepare_options!
      if options.slice(:html, :line_spacing, :line_height, :underline, :fragment_color).any?
        text_options = extract_attributed_text_options(options)

        html = text_options.delete(:html)
        text_options[:text] = html if html
        options[:attributed_text] = html ? html_string(text_options) : attributed_string(text_options)

        # ios 7 bug fix when text is invisible
        options[:number_of_lines] = 0 if text_options.slice(:line_height, :line_spacing, :text_alignment, :line_break_mode).any? && options.fetch(:number_of_lines, 1) == 1
      end
    end

    def extract_attributed_text_options(options)
      text_attributes = [
        :text, :html, :line_spacing, :line_height, :underline, :fragment_color,
        :text_alignment, :font, :line_break_mode, :number_of_lines
      ]
      attributed_text_options = options.slice(*text_attributes)
      options.except!(*text_attributes)
      attributed_text_options
    end

    def set_option(key, value)
      # return if value.nil?
      # ignore options
      return if key == 'section' && !view.respond_to?(:section=)
      return if key == 'size_to_fit' && view.is_a?(UILabel)
      return if %w[url default draw_in_rect].include?(key.to_s) && view.is_a?(UIImageView)
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
      elsif key == 'attributed_text'
        if view.is_a?(UIButton)
          view.setAttributedTitle value, forState: UIControlStateNormal
        else
          view.attributedText = value
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