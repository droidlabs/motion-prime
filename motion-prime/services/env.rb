module MotionPrime
  class Env
    def initialize
      @env = ENV['PRIME_ENV'] || RUBYMOTION_ENV || 'development'
    end

    def to_s
      @env
    end

    def inspect
      to_s
    end

    def method_missing(name, *args, &block)
      if /(.+)?$/.match(name)
        @env == name.gsub('?', '')
      else
        false
      end
    end
  end
end