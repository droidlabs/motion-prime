module MotionPrime
  class Styles
    @@repo = {}

    def initialize(namespace = nil)
      @namespace = namespace
    end

    def style(name, options = {})
      name = "#{@namespace}_#{name}".to_sym if @namespace
      @@repo[name] ||= {}
      if parent = options.delete(:parent)
        parent ="#{@namespace}_#{parent}".to_sym if @namespace
        @@repo[name].deep_merge! self.class.for(parent)
      end
      @@repo[name].deep_merge! options
    end

    class << self
      def define(namespace = nil, &block)
        self.new(namespace).instance_eval(&block)
      end

      def for(style_names)
        style_options = {}
        Array.wrap(style_names).each do |name|
          style_options.deep_merge!(@@repo[name] || {})
        end
        style_options
      end

      def extend_and_normalize_options(options = {})
        style_options = self.for(options.delete(:styles))
        normalize_options(style_options.merge(options))
      end

      def normalize_options(options)
        options.each do |key, option|
          options[key] = option.is_a?(Proc) && key != :block ? instance_eval(&option) : option
        end
      end
    end
  end
end