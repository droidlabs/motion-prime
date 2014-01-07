module MotionPrime
  class BaseHeaderSection < Section
    include CellSectionMixin
    DEFAULT_HEADER_HEIGHT = 20

    element :title, text: proc { @options[:title] }
    element :hint, text: proc { @options[:hint] }

    before_initialize :prepare_header_options

    def prepare_header_options
      @cell_type = :header
    end

    def render_element?(name)
      @options[name].present?
    end
  end
end