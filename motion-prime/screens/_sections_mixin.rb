module MotionPrime
  module ScreenSectionsMixin
    extend ::MotionSupport::Concern

    include HasClassFactory
    include HasNormalizer

    def self.included(base)
      base.class_attribute :_section_options
    end

    attr_accessor :_action_section_options

    def main_section
      @main_section || all_sections.first
    end

    def all_sections
      Array.wrap(@sections.try(:values))
    end

    def set_section(name, options = {})
      self._action_section_options ||= {}
      self._action_section_options[name.to_sym] = options
    end
    alias_method :section, :set_section

    protected
      def add_sections
        @main_section ||= nil
        create_sections
        render_sections
      end

      def create_sections
        section_options = self.class.section_options.merge(action_section_options)
        return unless section_options
        @sections = {}
        section_options.map do |name, options|
          section = create_section(name, options.clone)
          @sections[name] = section if section
        end
      end

      def create_section(name, options)
        section_class = class_factory("#{name}_section")
        options = normalize_options(options).merge(screen: self)
        !options.has_key?(:if) || options[:if] ? section_class.new(options) : nil
      end

      def action_section_options
        _action_section_options || {}
      end

      def render_sections
        return unless @sections.present?
        if all_sections.count > 1
          @main_section = MotionPrime::TableSection.new(model: all_sections, screen: self)
          @main_section.render
        else
          all_sections.first.render
        end
      end

    module ClassMethods
      def section_options
        _section_options || {}
      end

      def section(name, options = {})
        self._section_options ||= {}
        self._section_options[name.to_sym] = options

        define_method name do
          @sections[name]
        end
      end
    end
  end
end
