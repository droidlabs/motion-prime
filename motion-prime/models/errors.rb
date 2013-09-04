module MotionPrime
  class StoreError < StandardError; end
  class Errors
    class_attribute :fields
    self.fields = []

    def initialize(model)
      model.class.attributes.map(&:to_sym).each do |key|
        initialize_for_field key
      end
    end

    def initialize_for_field(name)
      self.class.fields << name.to_sym
      self.class.send :attr_accessor, name
    end

    def get(key)
      self.send(key) if respond_to?(key)
    end

    def set(key, value)
      initialize_for_field(key) unless respond_to?("#{key}=")
      self.send("#{key}=", value)
    end

    def [](attribute)
      get(attribute) || set(attribute.to_sym, [])
    end

    def []=(attribute, errors)
      set(attribute, errors)
    end

    def reset
      self.class.fields.each do |field|
        set(field, []) unless send(field).blank?
      end
    end
  end
end