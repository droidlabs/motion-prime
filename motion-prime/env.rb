module MotionPrime
  class Env
    def env
      (defined?(NSBundle) && NSBundle.mainBundle.objectForInfoDictionaryKey('PRIME_ENV')) || 
      ENV['PRIME_ENV'] || 
      ENV['RUBYMOTION_ENV'] || 
      (defined?(RUBYMOTION_ENV) && RUBYMOTION_ENV) || 
      'development'
    end

    def to_s
      env
    end

    def inspect
      env
    end

    def ==(obj)
      env == obj
    end

    def method_missing(name, *args, &block)
      if /(.+)?$/.match(name.to_s)
        env == name.to_s.gsub('?', '')
      else
        false
      end
    end
  end
end