module MotionPrime
  class Errors
    attr_accessor :_unique_keys

    def initialize(model)
      @_unique_keys = []
      @model = model
      model.class.attributes.map(&:to_sym).each do |key|
        initialize_for_key key
      end
    end

    def unique_key(key)
      [key, @model.object_id].join('_').to_sym
    end

    def initialize_for_key(key)
      unique_key = unique_key(key)

      return if @_unique_keys.include?(unique_key)
      @_unique_keys << unique_key
      instance_variable_set("@#{unique_key}", [])
      self.class.send :attr_accessor, unique_key
    end

    def get(key)
      initialize_for_key(key)
      send(unique_key(key))
    end

    def set(key, errors)
      initialize_for_key(key)
      send :"#{unique_key(key)}=", Array.wrap(errors)
    end

    def add(key, error)
      send(:"#{unique_key(key)}") << error
    end

    def [](key)
      get(key)
    end

    def []=(key, errors)
      set(key, errors)
    end

    def reset_for(key)
      send :"#{unique_key(key)}=", []
    end

    def reset
      @_unique_keys.each do |unique_key|
        send :"#{unique_key}=", []
      end
    end

    def messages
      @_unique_keys.map{ |uniq_k| send(uniq_k) }.compact.flatten
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