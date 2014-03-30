motion_require '../helpers/has_authorization'
module MotionPrime
  class Section
    # MotionPrime::Section is container for Elements.
    # Sections are located inside Screen and can contain multiple Elements.
    # On render, each element will be added to parent screen.

    # == Basic Sample
    # class MySection < MotionPrime::Section
    #   element :title, text: "Hello World"
    #   element :avatar, type: :image, image: 'defaults/avatar.jpg'
    # end
    #
    KEYBOARD_HEIGHT_PORTRAIT = 216
    KEYBOARD_HEIGHT_LANDSCAPE = 162
    DEFAULT_CONTENT_HEIGHT = 65
    include ::MotionSupport::Callbacks
    include HasAuthorization
    include HasNormalizer
    include HasClassFactory
    include DrawSectionMixin
    include DelegateMixin

    attr_accessor :screen, :model, :name, :options, :elements, :section_styles
    class_attribute :elements_options, :container_options, :keyboard_close_bindings
    define_callbacks :render, :initialize

    def initialize(options = {})
      @options = options

      run_callbacks :initialize do
        @options[:screen] = @options[:screen].try(:weak_ref)
        self.screen = options[:screen]
        @model = options[:model]
        @name = options[:name] ||= default_name
        @options_block = options[:block]
      end

      if Prime.env.development?
        @_section_info = "#{@name} #{screen.try(:class)}"
        @@_allocated_sections ||= []
        @@_allocated_sections << @_section_info
      end
    end

    def dealloc
      if Prime.env.development?
        index = @@_allocated_sections.index(@_section_info)
        @@_allocated_sections.delete_at(index)
      end
      Prime.logger.dealloc_message :section, self, self.name
      NSNotificationCenter.defaultCenter.removeObserver self # unbinding events created in bind_keyboard_events
      super
    end

    def strong_references
      [screen, screen.main_controller]
    end

    def container_bounds
      options[:container_bounds] or raise "You must pass `container bounds` option to prerender base section"
    end

    def has_container_bounds?
      options[:container_bounds].present?
    end

    # Get computed container options
    #
    # @return options [Hash] computed options
    def container_options
      compute_container_options! unless @container_options
      @container_options
    end

    # Get computed container height
    #
    # @example
    #   class MySection < Prime::Section
    #     container height: proc { element(:title).content_outer_height }
    #     element :title, text: 'Hello world'
    #   end
    #   section = MySection.new
    #   section.container_height # => 46
    #
    # @return height [Float, Integer] computed height
    def container_height
      container_options[:height] || DEFAULT_CONTENT_HEIGHT
    end

    # Get section default name, based on class name
    #
    # @example
    #   class ProfileSection < Prime::Section
    #   end
    #
    #   section = ProfileSection.new
    #   section.default_name # => 'profile'
    #   section.name         # => 'profile'
    #
    #   another_section = ProfileSection.new(name: 'another')
    #   another_section.default_name # => 'profile'
    #   another_section.name         # => 'another'
    #
    # @return name [String] section default name
    def default_name
      self.class_name_without_kvo.demodulize.underscore.gsub(/\_section$/, '')
    end

    # Get section elements options, where the key is element name.
    #
    # @return options [Hash] elements options
    def elements_options
      self.class.elements_options || {}
    end

    # Create elements if they are not created yet.
    # This will not cause rendering elements,
    # they will be rendered immediately after that or rendered async later, based on type of section.
    #
    # @return result [Boolean] true if has been loaded by this thread.
    def create_elements
      return if @section_loaded
      if @section_loading
        sleep 0.1
        return @section_loaded ? false : create_elements
      end
      @section_loading = true

      self.elements = {}
      elements_options.each do |key, opts|
        add_element(key, opts)
      end
      elements_eval(&@options_block) if @options_block.is_a?(Proc)

      @section_loading = false
      return @section_loaded = true
    end

    # Force reload section, will also re-render elements.
    # For table view cells will also reload it's table data.
    # Useful on some cases, but in common case please use #reload.
    #
    # @return [Boolean] true
    def hard_reload_section
      # reload Base Elements
      self.elements_to_render.values.map(&:view).flatten.each do |view|
        view.removeFromSuperview if view
      end
      render({}, true)
      # reload Draw Elements
      elements_to_draw.values.each(&:update)

      if @table && !self.is_a?(BaseFieldSection)
        cell.setNeedsDisplay
        @table.reload_table_data
      end
      true
    end

    # Reload section, will re-render elements.
    #
    # @return [Boolean] true
    def reload
      elements.values.each(&:update)
      true
    end

    def add_element(key, options = {})
      return unless render_element?(key)
      opts = options.clone
      index = opts.delete(:at)
      options = build_options_for_element(opts)
      options[:name] ||= key
      element = build_element(options)
      if index
        new_elements_array = elements.to_a.insert(index, [key, element])
        self.elements = Hash[new_elements_array]
      else
        self.elements[key] = element
      end
      element
    end

    def render_element?(element_name)
      true
    end

    def render(container_options = {}, force = false)
      force ? create_elements! : create_elements
      self.container_options.merge!(container_options)
      run_callbacks :render do
        render!
      end
    end

    def render_container(options = {}, &block)
      if should_render_container? && !self.container_element.try(:view)
        element = self.init_container_element(options)
        element.render do
          block.call
        end
      else
        block.call
      end
    end

    def render!
      render_container(container_options) do
        elements_to_render.each do |key, element|
          element.render
        end
      end
    end

    def element(name)
      self.elements ||= {}
      self.elements[name.to_sym]
    end

    def view(name)
      element(name).view
    end

    # Hide all elements of section.
    # It will hide all base elements and container of draw elements.
    # FIXME: container_view manipulation should be in draw mixin.
    def hide
      if container_view
        container_view.hidden = true
      end
      elements_to_render.values.each(&:hide)
    end

    # Show all elements of section.
    # It will show all base elements and container of draw elements.
    # FIXME: container_view manipulation should be in draw mixin.
    def show
      if container_view
        container_view.hidden = false
      end
      elements_to_render.values.each(&:show)
    end

    # Bring all views of section to front.
    # It will bring to front all base elements and container of draw elements.
    # FIXME: container_view manipulation should be in draw mixin.
    def bring_to_front
      if container_view
        container_view.superview.bringSubviewToFront container_view
      end
      elements_to_render.values.each do |element|
        element.view.superview.bringSubviewToFront element.view
      end
    end

    def on_keyboard_show; end
    def on_keyboard_hide; end
    def keyboard_will_show; end
    def keyboard_will_hide; end

    def bind_keyboard_events
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :on_keyboard_show,
                                             name: UIKeyboardDidShowNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :on_keyboard_hide,
                                             name: UIKeyboardDidHideNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :keyboard_will_show,
                                             name: UIKeyboardWillShowNotification,
                                           object: nil
      NSNotificationCenter.defaultCenter.addObserver self,
                                         selector: :keyboard_will_hide,
                                             name: UIKeyboardWillHideNotification,
                                           object: nil
    end

    def hide_keyboard
      elements = Array.wrap(keyboard_close_bindings_options[:elements])
      views = Array.wrap(keyboard_close_bindings_options[:views])

      elements.each do |el|
        views << el.view if el.try(:view) && %w[text_field text_view].include?(el.view_name)
      end
      views.compact.each(&:resignFirstResponder)
    end

    def elements_to_draw
      self.elements.select { |key, element| element.is_a?(DrawElement) }
    end

    def elements_to_render
      self.elements.except(*elements_to_draw.keys)
    end

    def current_input_view_height
      App.shared.windows.last.subviews.first.try(:height) || KEYBOARD_HEIGHT_PORTRAIT
    end

    def screen?
      screen && screen.weakref_alive?
    end

    protected
      def elements_eval_object
        self
      end

      def elements_eval(&block)
        elements_eval_object.instance_exec(self, &block)
      end

      def bind_keyboard_close
        bindings = self.class.keyboard_close_bindings
        return unless bindings.present?
        bind_proc = bindings[:tap_on]
        bind_views = instance_eval(&bind_proc)
        Array.wrap(bind_views).each do |view|
          gesture_recognizer = UITapGestureRecognizer.alloc.initWithTarget(self, action: :hide_keyboard)
          view.addGestureRecognizer(gesture_recognizer)
          gesture_recognizer.cancelsTouchesInView = false
        end
      end

      def keyboard_close_bindings_options
        return {} unless self.class.keyboard_close_bindings.present?
        @keyboard_close_bindings_options ||= normalize_options(self.class.keyboard_close_bindings.clone, elements_eval_object)
      end

      def build_options_for_element(opts)
        # we should clone options to prevent overriding options
        # in next element with same name in another class
        options = opts.clone
        options[:type] ||= (options[:text] || options[:html] || options[:attributed_text_options]) ? :label : :view
        options.merge(screen: screen, section: self.weak_ref)
      end

    private
      def should_render_container?
        has_drawn_content?
      end

      def has_drawn_content?
        elements_to_draw.any?
      end

      # Force load section
      #
      # @return result [Boolean] true if has been loaded by this thread.
      def create_elements!
        @section_loaded = false
        create_elements
      end

      def build_element(options = {})
        type = options.delete(:type)
        render_as = options.delete(:as).to_s
        if render_as != 'draw' && (render_as == 'view' || self.is_a?(BaseFieldSection) || self.is_a?(FormHeaderSection))
          BaseElement.factory(type, options)
        else
          DrawElement.factory(type, options) || BaseElement.factory(type, options)
        end
      end

      def compute_container_options!
        raw_options = {}
        raw_options.merge!(self.class.container_options.try(:clone) || {})
        raw_options.merge!(options.delete(:container) || {})

        # allow to pass styles as proc
        normalize_options(raw_options, elements_eval_object, nil, [:styles])
        @container_options = raw_options # must be here because section_styles may use container_options for custom styles

        container_options_from_styles = Styles.for(section_styles.values.flatten)[:container] if section_styles
        if container_options_from_styles.present?
          @container_options = container_options_from_styles.merge(@container_options)
        end
        normalize_options(@container_options, elements_eval_object)
      end

    class << self
      def inherited(subclass)
        subclass.elements_options = self.elements_options.try(:clone)
        subclass.container_options = self.container_options.try(:clone)
        subclass.keyboard_close_bindings = self.keyboard_close_bindings.try(:clone)
      end

      def element(name, options = {}, &block)
        options[:name] ||= name
        options[:type] ||= :label
        options[:block] = block
        self.elements_options ||= {}
        self.elements_options[name] = options
        self.elements_options[name]
      end
      def container(options)
        self.container_options = options
      end
      def before_render(*method_names, &block)
        set_callback :render, :before, *method_names, &block
      end
      def after_render(*method_names, &block)
        set_callback :render, :after, *method_names, &block
      end
      def before_initialize(*method_names, &block)
        set_callback :initialize, :before, *method_names, &block
      end
      def after_initialize(*method_names, &block)
        set_callback :initialize, :after, *method_names, &block
      end
      def bind_keyboard_close(options)
        self.keyboard_close_bindings = options
      end
    end
    after_render :bind_keyboard_events
    after_render :bind_keyboard_close
  end
end