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
    end

    def dealloc
      Prime.logger.dealloc_message :section, self, self.name
      NSNotificationCenter.defaultCenter.removeObserver self # unbinding events created in bind_keyboard_events
      super
    end

    def container_bounds
      options[:container_bounds] or raise "You must pass `container bounds` option to prerender base section"
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
    def load_section
      return if @section_loaded
      if @section_loading
        sleep 0.1
        return @section_loaded ? false : load_section
      end
      @section_loading = true
      create_elements
      @section_loading = false
      return @section_loaded = true
    end

    # Force load section
    #
    # @return result [Boolean] true if has been loaded by this thread.
    def load_section!
      @section_loaded = false
      load_section
    end

    # Force reload section, will also re-render elements.
    # For table view cells will also reload it's table data.
    def reload_section
      self.elements_to_render.values.map(&:view).flatten.each do |view|
        view.removeFromSuperview if view
      end
      load_section!
      run_callbacks :render do
        render!
      end

      if @table && !self.is_a?(BaseFieldSection)
        cell.setNeedsDisplay
        @table.reload_table_data
      end
    end

    def create_elements
      self.elements = {}
      elements_options.each do |key, opts|
        add_element(key, opts)
      end
      self.instance_eval(&@options_block) if @options_block.is_a?(Proc)
    end

    def load_elements
      self.elements.values.each do |element|
        element.size_to_fit_if_needed if element.is_a?(LabelDrawElement)
        element.compute_options! if element.respond_to?(:computed_options) && !element.computed_options
      end
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
    end

    def build_element(options = {})
      type = options.delete(:type)
      render_as = options.delete(:as).to_s
      if self.is_a?(BaseFieldSection) || self.is_a?(BaseHeaderSection) || render_as == 'view'
        BaseElement.factory(type, options)
      else
        DrawElement.factory(type, options) || BaseElement.factory(type, options)
      end
    end

    def render_element?(element_name)
      true
    end

    def cell
      container_view || begin
        first_element = elements.values.first
        first_element.view.superview.superview
      end
    end

    def render(container_options = {})
      load_section
      self.container_options.merge!(container_options)
      run_callbacks :render do
        render!
      end
    end

    def render_container(options = {}, &block)
      if should_render_container?
        element = self.container_element || self.init_container_element(options)
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
      elements[name.to_sym]
    end

    def view(name)
      element(name).view
    end

    def hide
      if container_view
        container_view.hidden = true
      else
        elements.values.each(&:hide)
      end
    end

    def show
      if container_view
        container_view.hidden = false
      else
        elements.values.each(&:show)
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
        views << el.view if %w[text_field text_view].include?(el.view_name) && el.view
      end
      views.compact.each(&:resignFirstResponder)
    end

    def elements_to_draw
      self.elements.select { |key, element| element.is_a?(DrawElement) }
    end

    def elements_to_render
      self.elements.select { |key, element| element.is_a?(BaseElement) }
    end

    protected
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
        @keyboard_close_bindings_options ||= normalize_options(self.class.keyboard_close_bindings.clone, self)
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
        self.elements.values.any? do |element|
          element.is_a?(DrawElement)
        end
      end

      def compute_container_options!
        raw_options = {}
        raw_options.merge!(self.class.container_options.try(:clone) || {})
        raw_options.merge!(options.delete(:container) || {})

        @container_options = raw_options

        # must be here because section_styles may use container_options for custom styles
        container_options_from_styles = Styles.for(section_styles.values.flatten)[:container] if section_styles
        if container_options_from_styles.present?
          @container_options = container_options_from_styles.merge(@container_options)
        end
        normalize_options(@container_options)
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
      def before_render(method_name)
        set_callback :render, :before, method_name
      end
      def after_render(method_name)
        set_callback :render, :after, method_name
      end
      def before_initialize(method_name)
        set_callback :initialize, :before, method_name
      end
      def after_initialize(method_name)
        set_callback :initialize, :after, method_name
      end
      def bind_keyboard_close(options)
        self.keyboard_close_bindings = options
      end
    end
    after_render :bind_keyboard_events
    after_render :bind_keyboard_close
  end
end