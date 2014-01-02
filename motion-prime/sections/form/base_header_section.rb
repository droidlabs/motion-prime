module MotionPrime
  class BaseHeaderSection < Section
    include CellSectionMixin
    DEFAULT_HEADER_HEIGHT = 20

    element :title, text: proc { @options[:title] }
    element :hint, text: proc { @options[:hint] }

    def initialize(options = {})
      @cell_type = :header
      super
    end

    def render_element?(name)
      @options[name].present?
    end
  end
end