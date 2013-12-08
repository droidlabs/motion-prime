module MotionPrime
  module ModelMethods
    def self.included(base)
      base.class_attribute :default_sort_options
    end

    def save
      raise StoreError, 'No store provided' unless self.store
      error_ptr = Pointer.new(:id)
      self.store.addObject(self, error: error_ptr)
      raise StoreError, error_ptr[0].description if error_ptr[0]
      self
    end

    def delete
      raise StoreError, 'No store provided' unless self.store

      error_ptr = Pointer.new(:id)
      self.store.removeObject(self, error: error_ptr)
      raise StoreError, error_ptr[0].description if error_ptr[0]
      self
    end

    def store
      super || self.class.store
    end

    def assign_attributes(new_attributes, options = {})
      attributes = new_attributes.symbolize_keys
      attributes.each do |k, v|
        if has_attribute?(k)
          assign_attribute(k, v) unless options[:skip_nil_values] && v.nil?
        elsif options[:check_attribute_presence]
          NSLog("unknown attribute: #{k}")
        else
          raise(NoMethodError, "unknown attribute: #{k}")
        end
      end
    end

    def assign_attribute(name, value)
      self.send("#{name}=", value) if has_attribute?(name)
    end

    def has_attribute?(name)
      respond_to?("#{name}=")
    end

    def attributes_hash
      self.info.to_hash.symbolize_keys
    end

    def new_record?
      id.blank?
    end

    def persisted?
      !new_record?
    end

    def model_name
      self.class_name_without_kvo.underscore
    end

    def inspect
      "#<#{self.class}:0x#{self.object_id.to_s(16)}> " + MotionPrime::JSON.generate(info)
    end
  end

  module ModelClassMethods
    # Initialize a new object
    #
    # Examples:
    #   User.new(name: "Bob", age: 10)
    #
    # @return MotionPrime::BaseModel unsaved model
    def new(data = {}, options = {})
      data.keys.each { |k|
        unless self.attributes.member? k.to_sym
          raise StoreError, "'#{k}' is not a defined attribute for this model"
        end
      }

      object = self.nanoObjectWithDictionary(data)
      object
    end

    # Initialize a new object and save it
    #
    # Examples:
    #   User.create(name: "Bob", age: 10)
    #
    # @return MotionPrime::BaseModel saved model
    def create(data = {})
      object = self.new(data)
      object.save
    end

    # Define model attribute
    #
    # Examples:
    #   class User < MotionPrime::BaseModel
    #     attribute :name
    #     attribute :age
    #   end
    #
    # @return Nil
    def attribute(name, options = {})
      attributes << name

      define_method(name) do |*args, &block|
        self.info[name]
      end

      define_method((name + "=").to_sym) do |*args, &block|
        value = args[0]
        case options[:type].to_s
        when 'integer' then value = value.to_i
        when 'float' then value = value.to_f
        end unless value.nil?

        self.info[name] = value
      end

      if options[:type].to_s == 'boolean'
        define_method("#{name}?") do
          !!self.info[name]
        end
      end
    end

    # Return all model attribute names
    #
    # @return Array array of attribute names
    def attributes(*attrs)
      if attrs.size > 0
        attrs.each{|attr| attribute attr}
      else
        @attributes ||= []
      end
    end

    # Return store associated with model class, or shared store by default
    #
    # @return MotionPrime::Store store
    def store
      @store ||= MotionPrime::Store.shared_store
    end

    # Define store associated with model class
    #
    # @param MotionPrime::Store store
    # @return MotionPrime::Store store
    def store=(store)
      @store = store
    end

    # Count of models
    #
    # @return Fixnum count
    def count
      self.store.count(self)
    end

    # Delete objects from store
    #
    # @param [Array, MotionPrime::BaseModel] objects to delete
    # @return [Array] result
    def delete(*args)
      keys = find_keys(*args)
      self.store.delete_keys(keys)
    end

    def default_sort(sort_options)
      self.default_sort_options = sort_options
    end
  end
end
