motion_require '../helpers/has_normalizer'
motion_require '../helpers/has_style_chain_builder'
motion_require '../helpers/has_class_factory'
module MotionPrime
  class BaseElement
    # MotionPrime::BaseElement is container for UIView class elements with options.
    # Elements are located inside Sections

    include ::MotionSupport::Callbacks
    include HasNormalizer
    include HasStyleChainBuilder
    include HasClassFactory
    extend HasClassFactory

    attr_accessor :options, :section, :name,
                  :view_class, :view, :view_name, :styles, :screen
    delegate :observing_errors?, :has_errors?, :errors_observer_fields, :observing_errors_for, to: :section, allow_nil: true
    define_callbacks :render

    def initialize(options = {})
      options[:screen] = options[:screen].try(:weak_ref)
      @options = options
      @screen = options[:screen]
      @section = options[:section]

      @view_class = options[:view_class] || 'UIView'
      @name = options[:name]
      @block = options[:block]
      @view_name = self.class_name_without_kvo.demodulize.underscore.gsub(/(_draw)?_element/, '')

      if Prime.env.development?
        info = []
        info << @name
        info << view_name
        info << section.try(:name)
        info << screen.class
        @_element_info = info.join(' ')
        @@_allocated_elements ||= []
        @@_allocated_elements << @_element_info
      end
    end

    def dealloc
      if Prime.env.development?
        index = @@_allocated_elements.index(@_element_info)
        @@_allocated_elements.delete_at(index) if index
      end
      Prime.logger.dealloc_message :element, self, self.name
      super
    end

    def add_target(target = nil, action = 'on_click:', event = :touch)
      return false unless self.view
      self.view.addTarget(target || section, action: action, forControlEvents: event.uicontrolevent)
    end

    def render(options = {}, &block)
      run_callbacks :render do
        render!(options, &block)
      end
    end

    def render!(options = {}, &block)
      view = screen.add_view class_factory(view_class), computed_options.merge(options) do |view|
        @view = view
        block.try(:call, view, self)
      end

      if computed_options.has_key?(:delegate) && computed_options[:delegate].respond_to?(:delegated_by)
        computed_options[:delegate].delegated_by(view)
      end
      view
    end

    # Lazy-computing options
    def computed_options
      compute_options! unless @computed_options
      @computed_options
    end

    def compute_options!
      block_options = compute_block_options || {}
      raw_options = self.options.except(:screen, :name, :block, :view_class).merge(block_options)
      compute_style_options(raw_options)
      raw_options = Styles.for(styles).merge(raw_options)
      @computed_options = raw_options
      normalize_options(@computed_options, section.try(:elements_eval_object), %w[
        font text placeholder title_label
        padding padding_left padding_right padding_top padding_bottom
        left right min_width min_outer_width max_width max_outer_width width
        top bottom min_height min_outer_height max_height max_outer_height height])
    end

    def reload!
      reset_computed_values
      compute_options!
    end

    def rerender!
      render_target = view.try(:superview)
      view.try(:removeFromSuperview)
      render(render_target: render_target)
      section.try(:on_element_render, self)
    end

    def update_with_options(new_options = {})
      options.merge!(new_options)
      reload!
      rerender!
    end

    def update_options(new_options)
      options.merge!(new_options)
      return unless view
      ViewStyler.new(view, view.superview.try(:bounds), new_options).apply
    end

    def update
      update_with_options({})
    end

    def hide
      view.hidden = true
    end

    def show
      view.hidden = false
    end

    def bind_gesture(action, receiver = nil)
      receiver ||= self
      single_tap = UITapGestureRecognizer.alloc.initWithTarget(receiver, action: action)
      view.addGestureRecognizer single_tap
      view.setUserInteractionEnabled true
    end

    def cell_section?
      section.respond_to?(:cell_section_name)
    end

    def cell_element?
      @view_class == 'UICollectionViewCell' || @view_class == 'UITableViewCell'
    end

    protected
      def reset_computed_values
        @content_height = nil
        @content_width = nil
      end

      # Compute options sent inside block, e.g.
      # element :button do
      #   {name: model.name}
      # end
      def compute_block_options
        normalize_value(@block, section) if @block
      end

      def compute_style_options(*style_sources)
        has_errors = section.respond_to?(:observing_errors?) && observing_errors? && has_errors?

        @styles = []
        if cell_section?
          @styles += compute_cell_style_options(style_sources, has_errors)
        end

        mixins = []
        custom_styles = []
        style_sources.each do |source|
          if source_mixins = source.delete(:mixins)
            mixins += Array.wrap(normalize_object(source_mixins, section.try(:elements_eval_object)))
          end
          if source_styles = source.delete(:styles)
            custom_styles += Array.wrap(normalize_object(source_styles, section.try(:elements_eval_object)))
          end
        end
        # styles got from mixins option
        @styles += mixins.map{ |m| :"_mixin_#{m}" }

        # don't use present? here, it's slower, while this method should be very fast
        if section && section.name && section.name != '' && name && name != ''
          # using for base sections
          @styles << [section.name, name].join('_').to_sym
        end

        # custom style (from options or block options), using for TableViews as well
        @styles += custom_styles
        # pp @view_class.to_s + @styles.inspect; puts()
        @styles
      end

      def compute_cell_style_options(style_sources, has_errors)
        base_styles = {common: [], specific: []}
        suffixes = {common: [], specific: []}
        all_styles = []

        # following example in Prime::TableSection#cell_section_styles
        # form element/cell: <base|user>_form_field, <base|user>_form_string_field, user_form_field_email
        # table element/cell: <base|categories>_table_cell, categories_table_title
        if section.section_styles
          section.section_styles.each { |type, values| base_styles[type] += values }
        end
        if @view_name != 'base' && !cell_element?
          # form element: _input
          # table element: _image
          suffixes[:common] << @view_name.to_sym
          suffixes[:common] << :"#{@view_name}_with_errors" if has_errors
        end
        if name && name.to_s != @view_name
          # form element: _input
          # table element: _icon
          suffixes[:specific] << name.to_sym
          suffixes[:specific] << :"#{name}_with_errors" if has_errors
        end
        # form cell: base_form_field, base_form_string_field
        # form element: base_form_field_string_field, base_form_string_field_text_field, base_form_string_field_input
        # table cell: base_table_cell
        # table element: base_table_cell_image
        common_styles = if suffixes[:common].any?
          build_styles_chain(base_styles[:common], suffixes.values.flatten)
        elsif suffixes[:specific].any?
          build_styles_chain(base_styles[:common], suffixes[:specific])
        elsif cell_element?
          base_styles[:common]
        end
        all_styles += Array.wrap(common_styles)
        # form cell: user_form_field, user_form_string_field, user_form_field_email
        # form element: user_form_field_text_field, user_form_string_field_text_field, user_form_field_email_text_field
        # table cell: categories_table_cell, categories_table_title
        # table element: categories_table_cell_image, categories_table_title_image
        specific_base_common_suffix_styles = if suffixes[:common].any?
          build_styles_chain(base_styles[:specific], suffixes[:common])
        elsif suffixes[:specific].empty? && cell_element?
          base_styles[:specific]
        end
        all_styles += Array.wrap(specific_base_common_suffix_styles)
        # form element: user_form_field_input, user_form_string_field_input, user_form_field_email_input
        # table element: categories_table_cell_icon, categories_table_title_icon
        all_styles += build_styles_chain(base_styles[:specific], suffixes[:specific])
        all_styles
      end

    class << self
      def factory(type, options = {})
        element_class = class_factory("#{type}_element", true) || self
        view_class_name = camelize_factory("ui_#{type}")

        options.merge!(view_class: view_class_name)
        element_class.new(options)
      end
      def before_render(method_name)
        set_callback :render, :before, method_name
      end
      def after_render(method_name)
        set_callback :render, :after, method_name
      end
    end
  end
end