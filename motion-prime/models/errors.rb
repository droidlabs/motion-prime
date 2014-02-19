module MotionPrime
  class Errors
    attr_accessor :info
    attr_reader :changes

    def initialize(model)
      @info = MotionSupport::HashWithIndifferentAccess.new
      @changes = MotionSupport::HashWithIndifferentAccess.new
      @model = model
      model.class.attributes.map(&:to_sym).each do |key|
        initialize_for_key key
      end
    end

    def get(key)
      initialize_for_key(key)
      @info[key]
    end

    def set(key, errors, options = {})
      initialize_for_key(key)

      track_changed options do
        @info[key] = Array.wrap(errors)
      end
    end

    def add(key, error, options = {})
      initialize_for_key(key)
      track_changed do
        @info[key] << error
      end
    end

    def [](key)
      get(key)
    end

    def []=(key, errors)
      set(key, errors)
    end

    def reset_for(key, options = {})
      track_changed options do
        @info[key] = []
      end
    end

    def reset
      track_changed do
        @info.keys.each do |key|
          reset_for(key, silent: true)
        end
      end
    end

    def messages
      @info.values.flatten
    end

    def blank?
      @info.values.none?
    end

    def present?
      !blank?
    end

    def to_s
      messages.join(';')
    end

    def track_changed(options = {})
      return yield if options[:silent]
      @changes = MotionSupport::HashWithIndifferentAccess.new
      saved_info = @info.clone
      willChangeValueForKey(:info)
      yield
      @info.each do |key, value|
        @changes[key] = [value, saved_info[key]] unless value == saved_info[key]
      end
      didChangeValueForKey(:info)
    end

    private
      def initialize_for_key(key)
        key = key.to_sym
        return if @info.has_key?(key)

        @info[key] ||= []
      end
  end
end