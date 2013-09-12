module MotionPrime
  class AssociationCollection < ::Array
    attr_reader :bag

    delegate :<<, to: :bag

    def initialize(bag, options, fetch_options = {})
      @bag = bag
      @association_name = options[:association_name]
      super(all(fetch_options))
    end

    def all(fetch_options = {})
      data = bag.to_a
      if sort_options = sort_options(fetch_options[:sort])
        data = data.sort do |a, b|
          left = []
          right = []
          sort_options.each do |key, order|
            if order == :desc
              left << b.send(key)
              right << a.send(key)
            else
              left << a.send(key)
              right << b.send(key)
            end
          end
          left <=> right
        end
      end
      data
    end

    def sort_options(options)
      return options if options
      model_class.default_sort_options
    end

    def model_class
      @model_class ||= @association_name.classify.constantize
    end
  end
end