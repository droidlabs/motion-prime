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
      options[:frame] = calculate_frame_for(bounds, options.merge(test: view.is_a?(UITextView)))
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
        if text_options.slice(:line_height, :line_spacing, :text_alignment, :line_break_mode).any? && options.fetch(:number_of_lines, 1) == 1
          options[:number_of_lines] = 0
        end
      end
      extract_font_options(options)
      extract_font_options(options, 'placeholder')
    end

    def extract_font_options(options, prefix = nil)
      key = [prefix, 'font'].compact.join('_').to_sym
      name_key = [prefix, 'font_name'].compact.join('_').to_sym
      size_key = [prefix, 'font_size'].compact.join('_').to_sym
      if options.slice(size_key, name_key).any?
        font_name = options.delete(name_key) || :system
        font_size = options.delete(size_key) || 14
        options[key] ||= font_name.uifont(font_size)
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
      return if ignore_option?(key)

      # apply options
      result ||= set_color_options(key, value)
      result ||= set_image_options(key, value)
      result ||= set_text_options(key, value)
      result ||= set_inset_options(key, value)
      result ||= set_layer_options(key, value)
      result ||= set_other_options(key, value)
      result ||= set_hash_options(key, value)

      unless result
        view.setValue value, forKey: low_camelize_factory(key)
      end
    end

    protected
      def set_color_options(key, value)
        if key.end_with?('color') && view.is_a?(UIControl)
          view.send :"set#{camelize_factory(key)}:forState", value.uicolor, UIControlStateNormal
          true
        elsif key.end_with?('color')
          color = value.try(:uicolor)
          color = color.cgcolor if view.is_a?(CALayer)
          view.send :"#{low_camelize_factory(key)}=", color
          true
        elsif key == 'gradient'
          gradient = prepare_gradient(value)
          view.layer.insertSublayer(gradient, atIndex: 0)
          true
        end
      end

      def set_image_options(key, value)
        if key.end_with?('background_image')
          if view.is_a?(UIControl) || view.is_a?(UISearchBar)
            view.send :"set#{camelize_factory(key)}:forState", value.uiimage, UIControlStateNormal
          else
            view.setBackgroundColor value.uiimage.uicolor
          end
          true
        elsif key.end_with?('background_view')
          if view.is_a?(UITableView)
            bg_view = UIView.alloc.initWithFrame(view.bounds)
            bg_view.backgroundColor = value[:color].uicolor
            view.backgroundView = bg_view
          else
            view.setValue value, forKey: low_camelize_factory(key)
          end
          true
        elsif key.end_with?('image')
          view.setValue value.uiimage, forKey: camelize_factory(key)
          true
        end
      end

      def set_text_options(key, value)
        if key.end_with?('alignment') && value.is_a?(Symbol)
          view.setValue value.uitextalignment, forKey: camelize_factory(key)
          true
        elsif key.end_with?('line_break_mode') && value.is_a?(Symbol)
          view.setValue value.uilinebreakmode, forKey: camelize_factory(key)
          true
        elsif key == 'autocapitalization'
          view.autocapitalizationType = UITextAutocapitalizationTypeNone if value === false
          true
        elsif key == 'attributed_text'
          if view.is_a?(UIButton)
            view.setAttributedTitle value, forState: UIControlStateNormal
          else
            view.attributedText = value
          end
          true
        end
      end

      def set_inset_options(key, value)
        if key.end_with?('_content_inset')
          current_inset = view.contentInset
          current_inset.send("#{key.partition('_').first}=", value)
          view.contentInset = current_inset
          true
        elsif key.end_with?('inset')
          inset = if value.to_s == 'none'
            UIEdgeInsetsMake(0, 320, 0, 0)
          elsif value.is_a?(Array) && value.count == 2
            UIEdgeInsetsMake(0, value.first, 0, value.last)
          elsif value.is_a?(Array) && value.count == 4
            UIEdgeInsetsMake(value[0], value[1], value[2], value[3])
          end
          view.send(:"#{low_camelize_factory(key)}=", inset) if inset
          true
        end
      end

      def set_layer_options(key, value)
        if key == 'rounded_corners'
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
          true
        end
      end

      def set_hash_options(key, value)
        if value.is_a?(Hash)
          self.class.new(
            view.send(low_camelize_factory(key).to_sym), nil,
            value.merge(parent_frame: options[:frame] || options[:parent_frame])
          ).apply
          true
        end
      end

      def set_other_options(key, value)
        if key == 'keyboard_type'
          view.setKeyboardType value.uikeyboardtype
          true
        elsif key == 'selection_style' && view.is_a?(UITableViewCell) && value.is_a?(Symbol)
          view.setSelectionStyle value.uitablecellselectionstyle
          true
        elsif key == 'estimated_cell_height' && view.is_a?(UITableView)
          view.setEstimatedRowHeight value
          true
        end
      end

      def ignore_option?(key)
        (key == 'section' && !view.respond_to?(:section=)) ||
        (key == 'size_to_fit' && view.is_a?(UILabel)) ||
        (%w[url default draw_in_rect].include?(key.to_s) && view.is_a?(UIImageView)) ||
        %w[
          styles has_drawn_content value_type height_to_fit container parent_frame
          width height top right bottom left
          max_width max_outer_width min_width min_outer_width
          max_height max_outer_height min_height min_outer_width
        ].include?(key.to_s)
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