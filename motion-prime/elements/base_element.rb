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
      @section = options[:section]
      @name = options.delete(:name)
      @view_class = options.delete(:view_class) || 'UIView'
      @screen = options.delete(:screen)
      @block = options.delete(:block)
      @view_name = self.class_name_without_kvo.demodulize.underscore.gsub(/(_draw)?_element/, '')
      @options = ComputedOptions.new(options, delegate: section)
      init_options
    end

    def dealloc
      # pp 'deallocating elemenet', self.name, self.to_s, view_class, view.try(:to_s)
      super
    end

    def add_target(target = nil, action = 'on_click:', event = :touch)
      return false unless self.view
      self.view.addTarget(target || section, action: action, forControlEvents: event.uicontrolevent)
    end

    def render(options = {}, &block)
      run_callbacks :render do
        render!(&block)
      end
    end

    def render!(&block)
      screen.add_view class_factory(view_class), options do |view|
        @view = view
        block.try(:call, view, self)
      end
    end

    def init_options
      @options.merge(compute_block_options || {})
      @options.add_styles compute_style_options(options)
    end

    def update_with_options(new_options = {})
      @options.merge!(new_options)
      view.try(:removeFromSuperview)
      @view = nil
      render
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

    protected

      # Compute options sent inside block, e.g.
      # element :button do
      #   {name: model.name}
      # end
      def compute_block_options
        section.send(:instance_exec, self, &@block) if @block
      end

      def compute_style_options(*style_sources)
        has_errors = section.respond_to?(:observing_errors?) && observing_errors? && has_errors?
        is_cell_section = section.respond_to?(:cell_name)

        @styles = []
        if is_cell_section
          base_styles = {common: [], specific: []}
          suffixes = {common: [], specific: []}

          # following example in Prime::TableSection#cell_styles
          # form element/cell: <base|user>_form_field, <base|user>_form_string_field, user_form_field_email
          # table element/cell: <base|categories>_table_cell, categories_table_title
          if section.section_styles
            section.section_styles.each { |type, values| base_styles[type] += values }
          end
          if %w[base table_view_cell].exclude?(@view_name)
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
          # form element: base_form_field_string_field, base_form_string_field_text_field
          # table cell: base_table_cell
          # table element: base_table_cell_image
          common_styles = if suffixes[:common].any?
            build_styles_chain(base_styles[:common], suffixes[:common])
          elsif suffixes[:specific].any?
            build_styles_chain(base_styles[:common], suffixes[:specific])
          elsif @view_name == 'table_view_cell'
            base_styles[:common]
          end
          @styles += Array.wrap(common_styles)

          # form cell: user_form_field, user_form_string_field, user_form_field_email
          # form element: user_form_field_text_field, user_form_string_field_text_field, user_form_field_email_text_field
          # table cell: categories_table_cell, categories_table_title
          # table element: categories_table_cell_image, categories_table_title_image
          specific_base_common_suffix_styles = if suffixes[:common].any?
            build_styles_chain(base_styles[:specific], suffixes[:common])
          elsif suffixes[:specific].empty? && @view_name == 'table_view_cell'
            base_styles[:specific]
          end
          @styles += Array.wrap(specific_base_common_suffix_styles)
          # form element: user_form_field_input, user_form_string_field_input, user_form_field_email_input
          # table element: categories_table_cell_icon, categories_table_title_icon
          @styles += build_styles_chain(base_styles[:specific], suffixes[:specific])
        end
        # don't use present? here, it's slower, while this method should be very fast
        if section && section.name && section.name != '' && name && name != ''
          # using for base sections
          @styles << [section.name, name].join('_').to_sym
        end
        # custom style (from options or block options), using for TableViews as well
        custom_styles = style_sources.map do |source|
          normalize_object(source.delete(:styles), section)
        end.flatten
        @styles += custom_styles
        # puts @view_class.to_s + @styles.inspect, ''
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