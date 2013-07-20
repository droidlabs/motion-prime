module MotionPrime
  module ModelMethods
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
  end

  module ModelClassMethods
    # Initialize a new object
    #
    # Examples:
    #   User.new(name: "Bob", age: 10)
    #
    # @return MotionPrime::BaseModel unsaved model
    def new(data = {})
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
    def attribute(name)
      attributes << name

      define_method(name) do |*args, &block|
        self.info[name]
      end

      define_method((name + "=").to_sym) do |*args, &block|
        self.info[name] = args[0]
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
  end
end
