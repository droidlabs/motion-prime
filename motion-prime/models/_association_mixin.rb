module MotionPrime
  module ModelAssociationMixin
    extend ::MotionSupport::Concern

    def _bags
      @_bags ||= {}
    end

    def bags_attributes
      # retrieving has_one/has_many bag keys
      self.class._associations.keys.inject({}) do |result, association_name|
        key = :"#{association_name.pluralize}_bag"
        result[key] = self.info[key] if self.info[key].present?
        result
      end
    end

    def bag_key_for(bag_name)
      self.info[bag_name]
    end

    # Saves model and all associations to store.
    #
    # @return [Prime::Model] model
    def save!
      _bags.values.each do |bag|
        bag.save# unless bag.store
      end
      super
    rescue StoreError => e
      raise e if Prime.env.development?
    end

    module ClassMethods
      # Defines bag associated with model, creates accessor for bag
      #
      # @param [String] name - the name of bag
      # @return [Nil]
      def bag(name)
        define_method(name) do |*args, &block|
          # use users_bag(true) to reload bag
          return _bags[name] if _bags[name] && args[0] != true
          bag_key = bag_key_for(name)
          if bag_key.present?
            bag = self.class.store.bagsWithKeysInArray([bag_key]).first
          end
          unless bag
            bag = Bag.bag
            self.info[name] = bag.key
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
          bag = self.send(bag_name)
          bag.clear
          bag << value
          value
        end
        define_method("#{association_name}_attributes=") do |value|
          bags_attributes = self.send(association_name).try(:bags_attributes) || {}
          self.send(bag_name).clear
          association = options.fetch(:class_name, association_name.classify).constantize.new
          association.info.merge!(bags_attributes)
          association.fetch_with_attributes(value)
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
          bags_attributes = self.send(bag_name).to_a.inject({}) do |result, item|
            result[item.id] = item.bags_attributes if item.id
            result
          end
          self.send(bag_name).clear

          pending_save_counter = 0
          collection = value.inject({}) do |result, attrs|
            model = options.fetch(:class_name, association_name.classify).constantize.new
            model.info.merge!(bags_attributes.fetch(attrs[:id], {}))
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
        define_method("#{association_name}") do |*args|
          bag = self.send(:"#{bag_name}")
          collection_options = {
            association_name: association_name,
            class_name: options.fetch(:class_name, association_name.classify),
            inverse_relation: {
              type: :has_one,
              name: self.class_name_without_kvo.demodulize.underscore,
              instance: self
            }
          }
          AssociationCollection.new(bag, collection_options, *args)
        end
      end

      def belongs_to(association_name, options = {})
        self._associations ||= {}
        self._associations[association_name] = {
          type: :belongs_to_one,
          class_name: options.fetch(:class_name, association_name.classify)
        }.merge(options)

        self.send(:attr_accessor, association_name)
      end
    end
  end
end