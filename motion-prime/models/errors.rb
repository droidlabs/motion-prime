module MotionPrime
  class Errors
    attr_accessor :keys
    attr_accessor :errors

    def initialize(model)
      @keys = []
      @errors = {}
      model.class.attributes.map(&:to_sym).each do |key|
        initialize_for_key key
      end
    end

    def initialize_for_key(key)
      @keys << key.to_sym unless @keys.include?(key.to_sym)
      @errors[key.to_sym] ||= []
    end

    def get(key)
      initialize_for_key(key)
      @errors[key.to_sym]
    end

    def set(key, errors)
      initialize_for_key(key)
      @errors[key.to_sym] = Array.wrap(errors)
    end

    def add(key, error)
      initialize_for_key(key)
      @errors[key.to_sym] << error
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
      errors.values.compact.flatten
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