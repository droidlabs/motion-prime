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
        if parent && (parent_namespace = options.delete(:parent_namespace) || @namespace)
          parent ="#{parent_namespace}_#{parent}".to_sym
        end
        mixins = Array.wrap(options.delete(:mixins)).map { |mixin_name| :"_mixin_#{mixin_name}" }

        names.each do |name|
          name = "#{@namespace}_#{name}".to_sym if @namespace
          @@repo[name] ||= {}
          @@repo[name].deep_merge!(self.class.for(parent, debug_missing: true, type: :parent, name: name)) if parent
          @@repo[name].deep_merge!(self.class.for(mixins, debug_missing: true, type: :mixin, name: name)) if mixins.present?
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
    alias_method :_, :style

    class << self
      include HasNormalizer

      def define(*namespaces, &block)
        @definition_blocks ||= []
        namespaces = Array.wrap(namespaces)
        if namespaces.any?
          namespaces.each do |namespace|
            @definition_blocks << {namespace: namespace, block: block}
          end
        else
          @definition_blocks << {namespace: false, block: block}
        end
      end

      def define!
        @definition_blocks.each do |definition|
          block = definition[:block]
          self.new(definition[:namespace]).instance_eval(&block)
        end
      end

      def for(style_names, options = {})
        style_options = {}
        Array.wrap(style_names).each do |name|
          styles = @@repo[name]
          Prime.logger.debug "No styles found for `#{name}` (element: `#{options[:name]}`, type: #{options.fetch(:type, 'general')})" if options[:debug_missing] && styles.blank?
          style_options.deep_merge!(styles || {})
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