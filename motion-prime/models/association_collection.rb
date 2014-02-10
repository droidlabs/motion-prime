module MotionPrime
  class AssociationCollection < ::Array
    attr_reader :bag, :association_name
    attr_reader :inverse_relation_name, :inverse_relation_key, :model_inverse_relation_name

    def initialize(bag, options, *args)
      @bag = bag
      @association_name = options[:association_name]
      bag.bare_class = model_class

      inverse_relation_options = options[:inverse_relation]
      define_inverse_relation(inverse_relation_options)

      @model_inverse_relation_name = (model_class._associations || {}).find do |name, options|
        options[:class_name] == inverse_relation.class_name_without_kvo
      end.try(:first)

      super all(*args)
    end

    # Initialize a new object and add to collection.
    #
    # @example:
    #   project.users.new(name: "Bob", age: 10)
    #
    # @params attributes [Hash] attributes beeing assigned to model
    # @return MotionPrime::Model unsaved model
    def new(attributes = {})
      record = model_class.new(attributes)
      add(record)
    end

    # Add model record to association collection.
    #
    # @example:
    #   project.users.new(name: "Bob", age: 10)
    #
    # @params record [Prime::Model] model which will be added to collection.
    # @return MotionPrime::Model model
    def add(record)
      set_inverse_relation_for(record)
      self.bag << record
      record
    end
    alias_method :<<, :add

    # Return all association records.
    #
    # @example:
    #   project.users.all
    #
    # @return Array<MotionPrime::Model> association records
    def all
      data = bag.to_a
      set_inverse_relation_for(data)
      data
    end
    alias_method :to_a, :all

    # Find association records.
    #
    # @example:
    #   project.users.find(age: 10)
    #
    # @params find_options [Hash] finder options.
    # @params sort_options [Hash] sorting options.
    # @return Array<MotionPrime::Model> association records
    def find(find_options = {}, sort_options = nil)
      find_options = build_find_options(find_options)
      sort_options = build_sort_options(sort_options)

      data = if bag.store.present?
        bag.find(find_options, sort_options)
      else
        bag.to_a.select do |entity| 
          find_options.all? { |field, value| entity.info[field] == value }
        end
      end
      set_inverse_relation_for(data)
      data
    end

    def model_class
      @model_class ||= @association_name.classify.constantize
    end

    # Remove all association records.
    #
    # @example:
    #   project.users.delete_all
    #
    # @return Array<MotionPrime::Model> association records
    def delete_all
      all.each { |obj| obj.delete }
    end

    private
      def build_find_options(options)
        options ||= {}
        options.merge!(bag_key: bag.key)
        if inverse_relation_key.present?
          {inverse_relation_key => inverse_relation.id}.merge options
        else
          options
        end
      end

      def build_sort_options(options)
        options || {sort: model_class.default_sort_options}
      end

      def set_inverse_relation_for(models)
        [*models].each do |model|
          model.send("#{inverse_relation_name}=", inverse_relation)
        end if model_inverse_relation_name.present?
      end

      def define_inverse_relation(options)
        # TODO: handle different relation types (habtm, has_one...)
        @inverse_relation_name = name = options[:name].to_sym
        self.class_eval do
          define_method name do
            options[:instance]
          end
          alias_method :inverse_relation, name
        end

        @inverse_relation_key = inverse_relation._associations[association_name][:foreign_key].try(:to_sym)
      end
  end
end