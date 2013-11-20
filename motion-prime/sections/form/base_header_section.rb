module MotionPrime
  class BaseHeaderSection < BaseSection
    include CellSection
    DEFAULT_HEADER_HEIGHT = 20

    element :title, text: proc { @options[:title] }

    attr_accessor :form

    def initialize(options = {})
      @form = options[:form]
      super
    end

    def style_options
      @style_options ||= Styles.for(section_styles.values.flatten)
    end

    def section_styles
      form.header_styles(self)
    end

    def container_height
      container_options[:height] || DEFAULT_HEADER_HEIGHT
    end
  end
end