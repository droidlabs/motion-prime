module MotionPrime
  def self.class_factory_cache
    @class_factory_cache ||= {}
  end

  def self.camelize_factory_cache
    @camelize_factory_cache ||= {}
  end

  def self.low_camelize_factory_cache
    @camelize_factory_cache ||= {}
  end

  def self.env
    ENV['PRIME_ENV'] || ENV['RUBYMOTION_ENV'] || 'development'
  end
end
::MP = MotionPrime unless defined?(::MP)
::Prime = MotionPrime unless defined?(::Prime)