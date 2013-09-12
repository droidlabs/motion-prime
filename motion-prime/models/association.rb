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
      klass = self

      define_method(name) do |*args, &block|
        return _bags[name] if _bags[name]

        bag_key = self.info[name]
        if bag_key.nil?
          bag = Bag.bag
          self.info[name] = bag.key
        else
          bag = self.class.store.bagsWithKeysInArray([bag_key]).first
        end

        association_name = name.gsub(/_bag$/, '')
        bag.bare_class = association_name.classify.constantize
        # back_relation_name = klass.name.demodulize.underscore.to_sym
        # bag.class_eval do
        #   attr_accessor back_relation_name
        # end unless bag.respond_to?(back_relation_name)

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
        association.fetch_with_attributes(value)
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

        pending_save_counter = 0
        collection = value.inject({}) do |result, attrs|
          model = association_name.classify.constantize.new
          model.fetch_with_attributes(attrs)
          unique_key = model.id || "pending_#{pending_save_counter+=1}"
          result.merge(unique_key => model)
        end
        association_data = collection.values
        self.send(:"#{bag_name}=", association_data)
        association_data
      end
      define_method("#{association_name}=") do |value|
        self.send(bag_name).clear
        self.send(:"#{bag_name}=", value)
      end
      define_method("#{association_name}") do |options = {}|
        bag = self.send(:"#{bag_name}")
        collection_options = {
          association_name: association_name
        }
        AssociationCollection.new(bag, collection_options, options)
      end
    end

    # def new(*args)
    #   super.tap do |model|
    #     (_associations || {}).keys.each do |association_name|
    #       back_relation_name = self.name.demodulize.underscore
    #       if bag.respond_to?(back_relation_name)
    #         bag.send("#{back_relation_name}=", model)
    #         bag = model.send("#{association_name}_bag")
    #       end
    #     end
    #   end
    # end
  end
end