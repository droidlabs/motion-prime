module MotionPrime
  class ComputedOptions
    include HasNormalizer
    def initialize(options = {}, params = {})
      @options = options
      @delegate = params[:delegate]
      @normalizer_args = Array.wrap(params[:normalizer_args])
    end

    def fetch(key)
      object = @options[key]
      if object.is_a?(Proc) || object.is_a?(Hash)
        @options[key] = normalize_object(object, @delegate, *@normalizer_args)
      else
        object
      end
    end

    def set(key, value)
      @options[key] = value
    end

    def [](key)
      fetch(key)
    end

    def []=(key, value)
      set(key, value)
    end

    def delete(key)
      @options.delete(key)
    end

    def add_styles(style_names, params = {})
      options = Styles.for(style_names)
      options = options[:container] if params[:container]
      @options = options.merge(@options) if options
      self
    end

    def merge(options)
      @options.merge(options)
      self
    end

    def merge!(options)
      @options.merge!(options)
      self
    end

    def to_hash
      compute!
      @options
    end

    def compute!(keys = nil)
      cached = @options.clone
      cached = cached.slice(keys) if keys
      cached.each do |key, value|
        fetch(key)
      end
    end

    def has_key?(key)
      @options.has_key?(key)
    end

    def slice(*args, &block)
      compute!(args)
      @options.slice(*args, &block)
    end

    def each(&block)
      to_hash.each(&block)
      self
    end
  end
end