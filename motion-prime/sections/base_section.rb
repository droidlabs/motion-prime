motion_require '../helpers/has_authorization'
module MotionPrime
  class BaseSection
    # MotionPrime::BaseSection is container for Elements.
    # Sections are located inside Screen and can contain multiple Elements.
    # On render, each element will be added to parent screen.

    # == Basic Sample
    # class MySection < MotionPrime::BaseSection
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
    include DrawMixin

    attr_accessor :screen, :model, :name, :options, :elements, :section_styles
    class_attribute :elements_options, :container_options, :keyboard_close_bindings, :cell_name
    define_callbacks :render

    def initialize(options = {})
      @options = options
      self.screen = options[:screen]
      @model = options[:model]
      @name = options[:name] ||= default_name
      @options_block = options[:block]
    end

    def container_options
      compute_container_options! unless @container_options
      @container_options
    end

    def container_height
      container_options[:height] || DEFAULT_CONTENT_HEIGHT
    end

    def default_name
      self.class_name_without_kvo.demodulize.underscore.gsub(/\_section$/, '')
    end

    def elements_options
      self.class.elements_options || {}
    end

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

    def load_section!
      @section_loaded = false
      load_section
    end

    def reload_section
      self.elements_to_render.values.map(&:view).flatten.compact.each { |view| view.removeFromSuperview }
      load_section!
      run_callbacks :render do
        render!
      end

      if @table && !self.is_a?(BaseFieldSection)
        cell.setNeedsDisplay
        @table.table_view.reloadData
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
        element.computed_options if element.respond_to?(:computed_options)
      end
    end

    def add_element(key, options)
      return unless render_element?(key)
      opts = options.clone
      index = opts.delete(:at)
      options = build_options_for_element(opts)
      options[:name] ||= key

      type = options.delete(:type)
      element = if self.is_a?(BaseFieldSection) || self.is_a?(BaseHeaderSection) || options.delete(:as).to_s == 'view'
        MotionPrime::BaseElement.factory(type, options)
      else
        MotionPrime::DrawElement.factory(type, options) || MotionPrime::BaseElement.factory(type, options)
      end

      if index
        self.elements = Hash[self.elements.to_a.insert index, [key, element]]
      else
        self.elements[key] = element
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
      self.container_options.merge!(container_options)
      load_section

      run_callbacks :render do
        render!
      end
    end

    def render!
      elements_to_render.each do |key, element|
        element.render
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

    def dealloc
      NSNotificationCenter.defaultCenter.removeObserver self
      self.delegate = nil if self.respond_to?(:delegate)
      super
    end

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

      elements.each { |el| views << el.view if %w[text_field text_view].include?(el.view_name) && el.view }
      views.compact.each(&:resignFirstResponder)
    end

    protected
      def bind_keyboard_close
        return unless self.class.keyboard_close_bindings.present?
        Array.wrap(self.instance_eval(&self.class.keyboard_close_bindings[:tap_on])).each do |view|
          gesture_recognizer = UITapGestureRecognizer.alloc.initWithTarget(self, action: :hide_keyboard)
          view.addGestureRecognizer(gesture_recognizer)
          gesture_recognizer.cancelsTouchesInView = false
        end
      end

      def keyboard_close_bindings_options
        @keyboard_close_bindings_options ||= normalize_options(self.class.keyboard_close_bindings.clone, self)
      end
      def elements_to_draw
        self.elements.select { |key, element| element.is_a?(DrawElement) }
      end

      def elements_to_render
        self.elements.select { |key, element| element.is_a?(BaseElement) }
      end

      def build_options_for_element(opts)
        # we should clone options to prevent overriding options
        # in next element with same name in another class
        options = opts.clone
        options[:type] ||= (options[:text] || options[:attributed_text_options]) ? :label : :view
        options.merge(screen: screen, section: self)
      end

    private
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
      def bind_keyboard_close(options)
        self.keyboard_close_bindings = options
      end
      def set_cell_name(value)
        self.cell_name = value
      end
    end
    after_render :bind_keyboard_events
    after_render :bind_keyboard_close
  end
end