motion_require '../header'
module MotionPrime
  class FormHeaderSection < HeaderSection
    DEFAULT_HEADER_HEIGHT = 20

    element :title, text: proc { @options[:title] }
    element :hint, text: proc { @options[:hint] }

    def render_element?(name)
      @options[name].present?
    end
  end
end