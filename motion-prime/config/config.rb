module MotionPrime
  class Config
    attr_accessor :attributes
    
    def initialize(attributes = {})
      @attributes = attributes || {}
    end

    def [](key)
      @attributes.has_key?(key.to_sym) ? fetch(key) : store(key, self.class.new)
    end

    def store(key, value)
      @attributes[key.to_sym] = value
    end
    alias :[]= :store

    def fetch(key, default = nil)
      @attributes[key.to_sym] || default
    end

    def nil?
      @attributes.empty?
    end
    alias :blank? :nil?

    def present?
      !blank?
    end

    def has_key?(key)
      !self[key].is_a?(self.class)
    end

    def to_hash
      hash = {}
      @attributes.each do |key, value|
        hash[key] = value.is_a?(MotionPrime::Config) ? value.to_hash : value
      end
      hash
    end

    class << self
      def method_missing(name, *args, &block)
        @base_config ||= self.new()
        @base_config.send(name.to_sym, *args, &block)
      end

      def configure(&block)
        @configure_blocks ||= []
        @configure_blocks << block
      end

      def configure!
        @configure_blocks ||= []
        @base_config ||= self.new()
        @configure_blocks.each do |block|
          block.call(@base_config)
        end
        setup_models
        setup_colors
        setup_fonts
        setup_logger
      end

      def setup_models
        MotionPrime::Store.connect
      end

      def setup_colors
        return unless @base_config
        colors = @base_config.colors.to_hash.inject({}) do |res, (color, value)|
          unless color == :prefix
            unless @base_config.colors.prefix.nil?
              res[:"#{@base_config.colors.prefix}_#{color}"] = value
            end
            res[:"app_#{color}"] = value
          end
          res
        end
        Symbol.css_colors.merge!(colors)
      end

      def setup_fonts
        return unless @base_config
        colors = @base_config.fonts.to_hash.inject({}) do |res, (font, value)|
          if [:system, :bold, :italic, :monospace].include?(value)
            value = Symbol.uifont[value]
          end
          unless font == :prefix
            unless @base_config.fonts.prefix.nil?
              res[:"#{@base_config.fonts.prefix}_#{font}"] = value
            end
            res[:"app_#{font}"] = value
          end
          res
        end
        Symbol.uifont.merge!(colors)
      end

      def setup_logger
        Prime::Logger.level = @base_config.logger.level
        Prime::Logger.dealloc_items =  @base_config.logger.dealloc_items
      end
    end

    def method_missing(name, *args, &block)
      if block_given?
        yield self[name]
      else
        name = name.to_s
        if /(.+)\=$/.match(name)
          store($1, args[0])
        elsif /(.+)\?$/.match(name)
          value = self[$1]
          value.present? && !!value
        else
          self[name]
        end
      end
    end
  end
end