module MotionPrime
  class Errors
    attr_accessor :keys

    def initialize(model)
      @keys = []
      model.class.attributes.map(&:to_sym).each do |key|
        initialize_for_key key
      end
    end

    def initialize_for_key(key)
      return if @keys.include?(key.to_sym)
      @keys << key.to_sym unless @keys.include?(key.to_sym)
      unless instance_variable_get("@#{key}")
        instance_variable_set("@#{key}", [])
      end
      self.class.send :attr_accessor, key.to_sym
    end

    def get(key)
      initialize_for_key(key)
      send(:"#{key.to_sym}")
    end

    def set(key, errors)
      initialize_for_key(key)
      send :"#{key.to_sym}=", Array.wrap(errors)
    end

    def add(key, error)
      get(key) << error
    end

    def [](key)
      get(key)
    end

    def []=(key, errors)
      set(key, errors)
    end

    def reset
      @keys.each do |key|
        set(key, [])
      end
    end

    def messages
      @keys.map{ |k| get(k)}.compact.flatten
    end

    def blank?
      messages.blank?
    end

    def present?
      !blank?
    end

    def to_s
      messages.join(';')
    end
  end
end