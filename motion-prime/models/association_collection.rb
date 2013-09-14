module MotionPrime
  class AssociationCollection < ::Array
    attr_reader :bag, :association_name
    attr_reader :inverse_relation_name, :inverse_relation_key, :model_inverse_relation_name

    delegate :<<, to: :bag

    def initialize(bag, options, *args)
      @bag = bag
      @association_name = options[:association_name]
      bag.bare_class = model_class

      inverse_relation_options = options[:inverse_relation]
      define_inverse_relation(inverse_relation_options)

      @model_inverse_relation_name = (model_class._associations || {}).find do |name, options|
        options[:class_name] == inverse_relation.class.name
      end.try(:first)

      super all(*args)
    end

    def new(attributes = {})
      model_class.new(attributes).tap do |model|
        set_inverse_relation_for(model)
      end
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

    def all(*args)
      return [] unless bag.store.present?
      data = bag.find(find_options(args[0]), sort_options(args[1]))
      set_inverse_relation_for(data)
      data
    end

    def set_inverse_relation_for(models)
      [*models].each do |model|
        model.send("#{inverse_relation_name}=", inverse_relation)
      end if model_inverse_relation_name.present?
    end

    def find_options(options)
      options ||= {}
      if inverse_relation_key.present?
        {inverse_relation_key => inverse_relation.id}.merge options
      else
        options
      end
    end

    def sort_options(options)
      return options if options.present?
      {sort: model_class.default_sort_options}
    end

    def model_class
      @model_class ||= @association_name.classify.constantize
    end
  end
end