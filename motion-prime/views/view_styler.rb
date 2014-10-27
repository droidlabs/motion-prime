module MotionPrime
  class ViewStyler
    include FrameCalculatorMixin
    include HasStyles
    include HasClassFactory
    include ElementTextMixin
    include HasStyleOptions

    ORDER = %w[
      frame
      font text title_label title
      minimum_value maximum_value value
      ]

    attr_reader :view, :options

    def initialize(view, parent_bounds = CGRectZero, options = {})
      @options = Styles.extend_and_normalize_options(options)
      @view = view
      prepare_frame_for(parent_bounds) if @options.delete(:calculate_frame)
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

    def prepare_frame_for(parent_bounds)
      options[:frame] = calculate_frame_for(parent_bounds, options)
      if options.slice(:width, :height, :right, :bottom, :height_to_fit).values.any?
        mask = UIViewAutoresizingNone
        mask |= UIViewAutoresizingFlexibleTopMargin if options[:top].nil?
        mask |= UIViewAutoresizingFlexibleLeftMargin if options[:left].nil?
        mask |= UIViewAutoresizingFlexibleBottomMargin if options[:bottom].nil?
        mask |= UIViewAutoresizingFlexibleRightMargin if options[:right].nil?
        mask |= UIViewAutoresizingFlexibleWidth if options[:width].nil? && (!options[:left].nil? && !options[:right].nil?)
        mask |= UIViewAutoresizingFlexibleHeight if options[:height].nil? && options[:height_to_fit].nil? && (!options[:top].nil? && !options[:bottom].nil?)
        options[:autoresizingMask] = mask
      end
    end

    def prepare_options!
      if options[:size_to_fit]
        options[:line_break_mode] ||= :word_wrap
        options[:number_of_lines] ||= 0 if view.is_a?(UILabel)
      end

      if options.slice(:html, :line_spacing, :line_height, :underline, :fragment_color).any?
        text_options = extract_attributed_text_options(options)
        html = text_options.delete(:html)
        text_options[:text] = html if html
        options[:attributed_text] = html ? html_string(text_options) : attributed_string(text_options)

        # ios 7 bug fix when text is invisible
        if view.is_a?(UILabel) && text_options.slice(:line_height, :line_spacing, :text_alignment, :line_break_mode).any? && options.fetch(:number_of_lines, 1) == 1
          options[:number_of_lines] = 0
        end
      end
      # Fix issue overriding background color
      if options[:background_image].present?
        options.delete(:background_color)
      end
      extract_font_options(options)
      extract_font_options(options, 'placeholder')

      @options = Hash[options.sort_by {|k,v| ORDER.index(k.to_s) || ORDER.count }]
    end

    def extract_font_options(options, prefix = nil)
      key = [prefix, 'font'].compact.join('_').to_sym
      options[key] = extract_font_from(options, prefix)
    end

    def extract_attributed_text_options(options)
      text_attributes = [
        :text, :html, :line_spacing, :line_height, :underline, :fragment_color,
        :text_alignment, :font, :font_name, :font_size, :line_break_mode, :number_of_lines, :text_color
      ]
      attributed_text_options = options.slice(*text_attributes)
      exclude_attributes = text_attributes
      if view.is_a?(UIButton)
        attributed_text_options[:text_color] ||= options[:title_color]
        attributed_text_options[:text] ||= options[:title]
        exclude_attributes.delete(:line_break_mode)
      end
      options.except!(*exclude_attributes)
      attributed_text_options
    end

    def set_option(key, value)
      # return if value.nil?
      # ignore options
      return if ignore_option?(key) || value.nil?

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
        if key.end_with?('background_image') && ui_image = value.uiimage
          if view.is_a?(UIControl) || view.is_a?(UISearchBar)
            view.send :"set#{camelize_factory(key)}:forState", ui_image, UIControlStateNormal
          else
            view.setBackgroundColor ui_image.uicolor
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
          if ui_image = value.uiimage
            ui_image = ui_image.imageWithRenderingMode(2) if options[:tint_color]
            view.setValue ui_image, forKey: camelize_factory(key)
          end
          true
        end
      end

      def set_text_options(key, value)
        if key == 'content_horizontal_alignment' && value.is_a?(Symbol) && %[left right center fill].include?(value.to_s)
          view.setValue class_factory("UIControlContentHorizontalAlignment_#{value.camelize}"), forKey: camelize_factory(key)
          true
        elsif key == 'content_vertical_alignment' && value.is_a?(Symbol) && %[top bottom center fill].include?(value.to_s)
          view.setValue class_factory("UIControlContentVerticalAlignment_#{value.camelize}"), forKey: camelize_factory(key)
          true
        elsif key.end_with?('alignment') && value.is_a?(Symbol)
          view.setValue value.nstextalignment, forKey: camelize_factory(key)
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
        elsif key.end_with?('inset') || key.end_with?('indicator_insets') || (key.end_with?('insets') && value.is_a?(Array))
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
          layer_bounds = bounds
          if value[:overlap]
            size = layer_bounds.size
            size.height += value.fetch(:border_width, 0) # overlap to the next cell
            layer_bounds.size = size
          end

          radius = value[:radius].to_f
          corner_consts = {top_left: UIRectCornerTopLeft, bottom_left: UIRectCornerBottomLeft, bottom_right: UIRectCornerBottomRight, top_right: UIRectCornerTopRight}
          corners = value[:corners].inject(0) { |result, corner| result|corner_consts[corner] }
          mask_path = UIBezierPath.bezierPathWithRoundedRect(layer_bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(radius, radius))

          mask_layer = CAShapeLayer.layer

          mask_layer.frame = layer_bounds
          mask_layer.path = mask_path.CGPath
          view.mask = mask_layer

          if value[:border_color] && value[:border_width]
            stroke_bounds = layer_bounds
            stroke_path = UIBezierPath.bezierPathWithRoundedRect(stroke_bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(radius, radius))
            stroke_layer = CAShapeLayer.layer
            unless value[:sides]
              stroke_layer.path = stroke_path.CGPath
            else # suuport sides
              stroke_layer.path = stroke_path.CGPath
            end
            stroke_layer.fillColor = :clear.uicolor.cgcolor
            stroke_layer.strokeColor = value[:border_color].uicolor.cgcolor
            stroke_layer.lineWidth = value[:border_width].to_f

            stroke_layer.lineDashPattern = value[:dashes] if value[:dashes].present?

            container_view = view.delegate
            stroke_view = UIView.alloc.initWithFrame(stroke_bounds)
            stroke_view.userInteractionEnabled = false
            stroke_view.layer.addSublayer(stroke_layer)
            container_view.addSubview(stroke_view)
            view.addSublayer(stroke_layer)
          end
          true
        end
      end

      def set_hash_options(key, value)
        if value.is_a?(Hash)
          self.class.new(
            view.send(low_camelize_factory(key).to_sym), nil,
            value.merge(parent_frame: options[:frame] || options[:parent_frame], bounds: options[:bounds])
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
          font_name font_size placeholder_font_name placeholder_font_size placeholder_font
          bounds post_process
        ].include?(key.to_s)
      end

      def bounds
        # TODO: raise error if parent_frame is nill
        frame_size = options[:parent_frame].size
        bounds_options = options[:bounds] || {}
        CGRectMake(0, 0, bounds_options.fetch(:width, frame_size.width), bounds_options.fetch(:height, frame_size.height))
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
