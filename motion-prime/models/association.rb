module MotionPrime
  module ModelAssociationMethods
    def _bags
      @_bags ||= {}
    end

    def save
      _bags.values.each do |bag|
        bag.store = self.store
        bag.save
      end
      super
    end
  end
  module ModelAssociationClassMethods

    # Defines bag associated with model, creates accessor for bag
    #
    # @param [String] name - the name of bag
    # @return [Nil]
    def bag(name)
      define_method(name) do |*args, &block|
        return _bags[name] if _bags[name]

        bag_key = self.info[name]
        if bag_key.nil?
          bag = Bag.bag
          self.info[name] = bag.key
        else
          bag = self.class.store.bagsWithKeysInArray([bag_key]).first
        end

        _bags[name] = bag
      end

      define_method((name + "=").to_sym) do |*args, &block|
        bag = self.send(name)
        case args[0]
        when Bag
          bag.clear
          bag += args[0].saved.values
        when Array
          bag.clear
          bag += args[0]
        else
          raise StoreError, "Unexpected type assigned to bags, must be an Array or MotionPrime::Bag, now: #{args[0].class}"
        end
        bag
      end
    end

    # Defines has one association for model, creates accessor for association
    #
    # @param [String] name - the name of association
    # @return [Nil]
    def has_one(association_name, options = {})
      bag_name = "#{association_name.pluralize}_bag"
      self.bag bag_name.to_sym

      self._associations ||= {}
      self._associations[association_name] = options.merge(type: :one)

      define_method("#{association_name}=") do |value|
        self.send(bag_name).clear

        self.send(:"#{bag_name}") << value
        value
      end
      define_method("#{association_name}_attributes=") do |value|
        self.send(bag_name).clear

        association = association_name.classify.constantize.new
        association.sync_with_attributes(value)
        association.save
        self.send(:"#{bag_name}") << association
        association
      end
      define_method("#{association_name}") do
        self.send(:"#{bag_name}").to_a.first
      end
    end

    # Defines has many association for model, creates accessor for association
    #
    # @param [String] name - the name of association
    # @return [Nil]
    def has_many(association_name, options = {})
      bag_name = "#{association_name}_bag"
      self.bag bag_name.to_sym

      self._associations ||= {}
      self._associations[association_name] = options.merge(type: :many)

      define_method("#{association_name}_attributes=") do |value|
        self.send(bag_name).clear

        association = []
        value.each do |attrs|
          model = association_name.classify.constantize.new
          model.sync_with_attributes(attrs)
          association << model
        end
        self.send(:"#{bag_name}=", association)
        association
      end
      define_method("#{association_name}=") do |value|
        self.send(bag_name).clear
        self.send(:"#{bag_name}=", value)
      end
      define_method("#{association_name}") do
        self.send(:"#{bag_name}").to_a
      end
    end
  end
end