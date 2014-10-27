motion_require '../helpers/has_normalizer'
motion_require '../helpers/has_style_chain_builder'
motion_require '../helpers/has_class_factory'
motion_require '../helpers/has_style_options'
module MotionPrime
  class BaseElement
    # MotionPrime::BaseElement is container for UIView class elements with options.
    # Elements are located inside Sections

    include ::MotionSupport::Callbacks
    include HasNormalizer
    include HasStyleChainBuilder
    include HasClassFactory
    include HasStyleOptions
    extend HasClassFactory

    attr_accessor :options, :section, :name,
                  :view_class, :view, :view_name, :styles, :screen
    attr_reader :block
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
      @view_name = underscore_factory(self.class_name_without_kvo.demodulize).gsub(/(_draw)?_element/, '')

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
    rescue # "undefined `super` method" bug fix
      Prime.logger.debug "Undefined `super` in `base_element`"
    end

    def add_target(target = nil, action = 'on_click:', event = :touch)
      return false unless self.view
      self.view.addTarget(target || section, action: action, forControlEvents: event.uicontrolevent)
    end

    def notify_section_before_render
      section.try(:before_element_render, self)
    end

    def notify_section_after_render
      section.try(:after_element_render, self)
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

      if computed_options.has_key?(:delegate) && computed_options[:delegate].respond_to?(:delegated_by) && view.respond_to?(:setDelegate)
        computed_options[:delegate].delegated_by(view)
      end
      view
    end

    # Lazy-computing options
    def preload_options
      compute_options! if respond_to?(:computed_options) && !@computed_options
      size_to_fit_if_needed if is_a?(LabelDrawElement)
    end

    def computed_options
      @computed_options || compute_options!
    end

    def compute_options!
      @computed_options = ElementComputedOptions.new(self)
      computed_options
    end

    def reload!
      reset_computed_values
      compute_options!
    end

    def rerender!(changed_options = [])
      render_target = view.try(:superview)
      view.try(:removeFromSuperview)
      render(render_target: render_target)

      if (changed_options & [:text, :size_to_fit]).any? && respond_to?(:size_to_fit)
        size_to_fit
      end
    end

    def update_with_options(new_options = {})
      options.deep_merge!(new_options)
      reload!
      computed_options.deep_merge!(new_options)
      rerender!(new_options.keys)
    end

    def update_options(new_options)
      options.deep_merge!(new_options)
      return unless view

      required_options = if new_options.slice(:width, :height, :top, :left, :right, :bottom).any?
        new_options[:calculate_frame] = true
        [:width, :height, :top, :left, :right, :bottom]
      elsif new_options.slice(:text, :title).any?
        [:line_spacing, :line_height, :underline, :fragment_color, :text_alignment, :font, :font_name, :font_size, :line_break_mode, :number_of_lines]
      end
      new_options = computed_options.slice(*Array.wrap(required_options)).merge(new_options)

      ViewStyler.new(view, view.superview.try(:bounds), new_options).apply
    end

    def update
      update_with_options({})
    end

    def hide
      view.hidden = true if view # TODO: should we update computed options in opposite case?
    end

    def show
      view.hidden = false if view
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
      def reset_computed_values; end

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

    before_render :notify_section_before_render
    after_render :notify_section_after_render
  end
end