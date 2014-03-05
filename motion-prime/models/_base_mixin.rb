module MotionPrime
  module ModelBaseMixin
    extend ::MotionSupport::Concern

    def self.included(base)
      base.class_attribute :default_sort_options
    end

    # Saves model to default store.
    #
    # @return [Prime::Model] model
    def save
      set_default_id_if_needed
      raise StoreError, 'No store provided' unless self.store
      error_ptr = Pointer.new(:id)
      self.store.addObject(self, error: error_ptr)
      raise StoreError, error_ptr[0].description if error_ptr[0]
      self
    end

    # Removed model from default store.
    #
    # @return [Prime::Model] model
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

    # Assigns attributes to model
    #
    # @params attributes [Hash] attributes to be assigned
    # @params options [Hash] options
    # @option options [Boolean] :skip_nil_values Do not assign nil values
    # @option options [Boolean] :validate_attribute_presence Raise error if model do not have attribute
    # @return [Hash] attributes
    def assign_attributes(new_attributes, options = {})
      attributes = new_attributes.symbolize_keys
      attributes.each do |k, v|
        if has_attribute?(k)
          assign_attribute(k, v) unless options[:skip_nil_values] && v.nil?
        elsif options[:validate_attribute_presence]
          raise(StoreError, "unknown attribute: '#{k}'")
        else
          NSLog("unknown attribute: #{k}")
        end
      end
    end

    # Assigns attribute to model
    #
    # @params name [String, Symbol] attribute name
    # @params value [Object] attribute value
    # @return [Object] assigned object if has been assigned
    def assign_attribute(name, value)
      self.send("#{name}=", value) if has_attribute?(name)
    end

    # Check if model has attribute
    #
    # @params name [String, Symbol] attribute name
    # @return [Boolean] result
    def has_attribute?(name)
      respond_to?("#{name}=")
    end

    # Hash of all attributes in model
    #
    # @return [Hash] key-value hash
    def attributes_hash
      self.info.to_hash.symbolize_keys
    end

    # Checks if model has been saved in server (have an ID)
    #
    # @return [Boolean] true if model is not saved
    def new_record?
      id.blank?
    end

    # Checks if model has been saved in server (have an ID)
    #
    # @return [Boolean] true if model is saved
    def persisted?
      !new_record?
    end

    # Model class name
    #
    # @return [String] model class name
    def model_name
      self.class_name_without_kvo.underscore
    end

    # Returns json-formatted representation of model
    #
    # @return [String] model representation
    def inspect
      inspection = self.info.keys.map { |name|
        "#{name}: #{attribute_for_inspect(name)}"
      }.compact.join(", ")
      "#<#{self.class}:0x#{self.object_id.to_s(16)}> #{inspection}>"
    end

    # Returns a clone of the record with empty bags
    #
    # @return new [Prime::Model] model
    def clone
      self.class.new(self.info.select { |key, value| !key.to_s.ends_with?('_bag') })
    end

    protected
      def set_default_id_if_needed
        if !self.id && MotionPrime::Config.model.auto_generate_id
          self.id = RmDigest::MD5.hexdigest(Time.now.to_s + self.object_id.to_s)
        end
      end

      def attribute_convert_out(value, type)
        return value if value.nil? || type.blank?
        case type.to_s
        when 'integer'
          value.to_i
        when 'float'
          value.to_f
        when 'time'
          Time.short_iso8601(value)
        else
          value
        end
      end

      def attribute_convert_in(value, type)
        return value if value.nil? || type.blank?
        case type.to_s
        when 'integer'
          value.to_i
        when 'float'
          value.to_f
        when 'time'
          value.is_a?(String) ? value : value.to_short_iso8601
        else
          value
        end
      end

      def attribute_for_inspect(attribute)
        value = send(attribute)
        if value.nil?
          "nil"
        elsif value.is_a?(String)
          "\"#{value}\""
        else
          value.to_s
        end
      end

    module ClassMethods
      # Initialize a new object
      #
      # @example:
      #   User.new(name: "Bob", age: 10)
      #
      # @params attributes [Hash] attributes beeing assigned to model
      # @params options [Hash] options
      # @option options [Boolean] :validate_attribute_presence Raise error if model do not have attribute
      # @return MotionPrime::Model unsaved model
      def new(data = {}, options = {})
        object = self.nanoObjectWithDictionary({})
        object.assign_attributes(data, options)
        object
      end

      # Initialize a new object and save it to store
      #
      # @example:
      #   User.create(name: "Bob", age: 10)
      #
      # @params attributes [Hash] attributes beeing assigned to model
      # @return model [MotionPrime::Model] saved model
      def create(data = {})
        object = self.new(data)
        object.save
        object
      end

      # Define model attribute
      #
      # @example:
      #   class User < MotionPrime::Model
      #     attribute :name
      #     attribute :age
      #   end
      #
      # @return Nil
      def attribute(name, options = {})
        attributes << name

        define_method(:"#{name}=") do |value, &block|
          track_changed_attributes do
            if options[:convert] || !options.has_key?(:convert)
              self.info[name] = attribute_convert_in(value, options[:type])
            else
              self.info[name] = value
            end
          end
        end

        define_method(name.to_sym) do
          if options[:convert] || !options.has_key?(:convert)
            attribute_convert_out(self.info[name], options[:type])
          else
            self.info[name]
          end
        end

        define_method("#{name}?") do
          self.info[name].present?
        end
      end

      # Set and/or return all model attribute names
      #
      # @return array [Array<Symbol>] array of attribute names
      def attributes(*attrs)
        if attrs.size > 0
          attrs.each{|attr| attribute attr}
        end
        @attributes ||= []
      end

      # Return store associated with model class, or shared store by default
      #
      # @return store [MotionPrime::Store] store
      def store
        @store ||= MotionPrime::Store.shared_store
      end

      # Define store associated with model class
      #
      # @param store [MotionPrime::Store] store
      # @return store [MotionPrime::Store] store
      def store=(store)
        @store = store
      end

      # Count of models
      #
      # @return count [Fixnum] count of objects with this Prime::Model
      def count
        self.store.count(self)
      end

      # Delete objects from store by given options
      #
      # @example:
      #   User.delete(:name => "Bob") #
      #
      # @param options [Hash, Array, MotionPrime::Model] objects to delete. See find_keys for list of options.
      # @return keys [Array] removed item keys
      def delete(*args)
        if args.blank?
          raise "Using delete with no args is not allowed. Please use delete_all to delete all records"
        end
        keys = find_keys(*args)
        self.store.delete_keys(keys)
      end

      # Delete all objects with this Prime::Model
      #
      # @example:
      #   User.delete_all
      #
      # @return keys [Array] removed item keys
      def delete_all
        self.store.delete_keys(find_keys)
      end

      def default_sort(sort_options)
        self.default_sort_options = sort_options
      end
    end
  end
end
