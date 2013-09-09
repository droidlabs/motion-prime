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
    include MotionPrime::HasAuthorization
    include MotionPrime::HasNormalizer

    attr_accessor :screen, :model, :name, :options, :elements
    class_attribute :elements_options, :container_options
    define_callbacks :render

    def initialize(options = {})
      @options = options
      @model = options[:model]
      @name = options[:name] ||= default_name
      create_elements
      self.hide if container_options[:hidden]
    end

    def default_name
      self.class.name.demodulize.underscore.gsub(/\_section$/, '')
    end

    def elements_options
      self.class.elements_options || {}
    end

    def create_elements
      self.elements = {}
      elements_options.each do |key, opts|
        next unless render_element?(key)
        options = build_options_for_element(opts)
        self.elements[key] = MotionPrime::BaseElement.factory(options.delete(:type), options)
      end
    end

    def render_element?(element_name)
      true
    end

    def build_options_for_element(opts)
      # we should clone options to prevent overriding options
      # in next element with same name in another class
      options = opts.clone
      options.merge(section: self)
    end

    def cell
      first_element = elements.values.first
      first_element.view.superview
    end

    def render(container_options = {})
      self.container_options.merge!(container_options)
      self.screen = container_options.delete(:to)
      run_callbacks :render do
        render!
      end
    end

    def render!
      elements.each do |key, element|
        element.render(to: screen)
      end
    end

    def element(name)
      elements[name.to_sym]
    end

    def view(name)
      element(name).view
    end

    def hide
      elements.values.each do |element|
        element.view.hidden = true
      end
    end

    def show
      elements.values.each do |element|
        element.view.hidden = false
      end
    end

    def container_options
      @container_options ||= normalize_options(
        self.class.container_options.try(:clone) || {}
      )
    end

    def container_height
      container_options[:height] || DEFAULT_CONTENT_HEIGHT
    end

    def container_styles
      container_options[:styles]
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

    class << self
      def element(name, options = {}, &block)
        options[:type] ||= :label
        options[:name] = name
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
    end
    after_render :bind_keyboard_events

  end
end