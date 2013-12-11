motion_require '../helpers/has_normalizer'
module MotionPrime
  class Styles
    @@repo = {}

    def initialize(namespace = nil)
      @namespace = namespace
    end

    def style(*args, &block)
      names = Array.wrap(args)
      options = names.pop if args.last.is_a?(Hash)

      if options.present?
        parent = options.delete(:parent)
        if parent_namespace = options.delete(:parent_namespace) || @namespace
          parent ="#{parent_namespace}_#{parent}".to_sym
        end
        mixins = Array.wrap(options.delete(:mixins)).map { |mixin_name| :"_mixin_#{mixin_name}" }

        names.each do |name|
          name = "#{@namespace}_#{name}".to_sym if @namespace
          @@repo[name] ||= {}
          @@repo[name].deep_merge!(self.class.for(parent)) if parent
          @@repo[name].deep_merge!(self.class.for(mixins)) if mixins.present?
          @@repo[name].deep_merge! options
        end
      elsif !block_given?
        raise "No style rules specified for `#{names.join(', ')}`. Namespace: `#{@namespace}`"
      end

      names.each do |name|
        namespace = [@namespace, name].compact.join('_')
        self.class.new(namespace).instance_eval(&block)
      end if block_given?
    end

    class << self
      include HasNormalizer

      def define(*namespaces, &block)
        Array.wrap(namespaces).each do |namespace|
          self.new(namespace).instance_eval(&block)
        end
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
    end
  end
end