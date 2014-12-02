module MotionPrime
  class BaseComputedOptions < ::Hash
    def initialize
      super
      @_keys = {}
      @_cached_values = {}
    end

    def slice(*keys)
      keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
      keys.each_with_object(Hash.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
    end

    def fetch(*args)
      key = args.shift
      return(args.count == 1 ? args.first : raise("`#{key}` key not found")) unless has_key?(key)
      self[key]
    end

    def delete(key)
      value = self[key]
      reset_key(key)
      super
      value
    end

    def [](name)
      @_keys[name.to_s].try(:wait)
      @_keys[name.to_s] ||= Dispatch::Semaphore.new(0)
      if @_cached_values.has_key?(name.to_s)
        @_keys[name.to_s].try(:signal)
        return @_cached_values[name.to_s]
      end
      result = @_cached_values.fetch(name.to_s, normalizer.normalize_object(super, receiver))
      @_cached_values[name.to_s] = result
      @_keys[name.to_s].try(:signal)
      result
    end

    def []=(key, value)
      reset_key(key)
      super
    end

    def merge!(hash)
      result = super
      hash.keys.each { |key| reset_key(key) }
      result
    end

    def deep_merge!(hash)
      result = super
      hash.keys.each { |key| reset_key(key) }
      result
    end

    def reset_key(key)
      @_keys[key.to_s].try(:signal)
      @_keys.delete(key.to_s)
      @_cached_values.delete(key.to_s)
    end

    def receiver
      raise "Implement"
    end
  end
end