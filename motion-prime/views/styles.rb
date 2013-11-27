motion_require '../helpers/has_normalizer'
module MotionPrime
  class Styles
    @@repo = {}

    def initialize(namespace = nil)
      @namespace = namespace
    end

    def style(*args)
      names = Array.wrap(args)
      options = names.pop if args.last.is_a?(Hash)

      raise "No style rules specified for `#{names.join(', ')}`. Namespace: `#{@namespace}`" unless options
      parent = options.delete(:parent)
      namespace = options.delete(:parent_namspace) || @namespace
      parent ="#{namespace}_#{parent}".to_sym if namespace

      names.each do |name|
        name = "#{@namespace}_#{name}".to_sym if @namespace
        @@repo[name] ||= {}
        @@repo[name].deep_merge!(self.class.for(parent)) if parent
        @@repo[name].deep_merge! options
      end
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