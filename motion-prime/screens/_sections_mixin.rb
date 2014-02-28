module MotionPrime
  module ScreenSectionsMixin
    extend ::MotionSupport::Concern

    include HasClassFactory
    include HasNormalizer

    def self.included(base)
      base.class_attribute :_section_options
    end

    def add_sections
      @main_section = nil
      create_sections
      render_sections
    end

    def all_sections
      Array.wrap(@sections.try(:values))
    end

    def create_sections
      section_options = self.class._section_options
      return unless section_options
      @sections = {}
      section_options.map do |name, options|
        section = create_section(options.clone)
        @sections[name] = section if section
      end
    end

    def create_section(options)
      section_class = class_factory("#{options.delete(:name)}_section")
      options = normalize_options(options).merge(screen: self)
      !options.has_key?(:if) || options[:if] ? section_class.new(options) : nil
    end

    def render_sections
      return unless @sections
      if all_sections.count > 1
        @main_section = MotionPrime::TableSection.new(model: all_sections, screen: self)
        @main_section.render
      else
        all_sections.first.render
      end
    end

    def main_section
      @main_section || all_sections.first
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
