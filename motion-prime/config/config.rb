module MotionPrime
  class Config
    def initialize(attributes = {})
      @attributes = attributes || {}
    end

    def [](key)
      fetch(key.to_sym) || store(key, self.class.new)
    end

    def store(key, value)
      @attributes[key.to_sym] = value
    end
    alias :[]= :store

    def fetch(key)
      @attributes[key.to_sym]
    end

    def nil?
      @attributes.empty?
    end
    alias :blank? :nil?

    def has_key?(key)
      !self[key].is_a?(self.class)
    end

    class << self
      def method_missing(name, *args, &block)
        @base_config ||= self.new()
        @base_config.send(name.to_sym, *args, &block)
      end
    end

    def method_missing(name, *args, &block)
      if block_given?
        yield self[name]
      else
        name = name.to_s
        if /(.+)=$/.match(name)
          return store($1, args[0])
        else
          return self[name]
        end
      end
    end
  end
end