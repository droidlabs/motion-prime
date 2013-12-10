module MotionPrime
  class BaseHeaderSection < BaseSection
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

    def container_height
      container_options[:height] || DEFAULT_HEADER_HEIGHT
    end
  end
end