module MotionPrime
  module ScreenSectionsMixin
    extend ::MotionSupport::Concern

    include HasClassFactory
    include HasNormalizer

    def self.included(base)
      base.class_attribute :_section_options
    end

    def add_sections
      create_sections
      render_sections
    end

    def create_sections
      section_options = self.class._section_options
      return unless section_options
      @sections = {}
      section_options.map do |name, options|
        @sections[name] = create_section(options.clone)
      end
    end

    def create_section(options)
      section_class = class_factory("#{options.delete(:name)}_section")
      options = normalize_options(options).merge(screen: self)
      section_class.new(options)
    end

    def render_sections
      return unless @sections
      if @sections.count > 1
        @main_section = MotionPrime::TableSection.new(model: @sections.values, screen: self)
        @main_section.render
      else
        @sections.first.render
      end
    end

    def main_section
      @main_section || @sections.first
    end

    module ClassMethods
      def section(name, options = {})
        self._section_options ||= {}
        self._section_options[name.to_sym] = options.merge(name: name)

        define_method name do
          @sections[name]
        end
      end
    end
  end
end
