module MotionPrime
  def self.class_factory_cache
    @class_factory_cache ||= {}
  end

  def self.camelize_factory_cache
    @camelize_factory_cache ||= {}
  end

  def self.low_camelize_factory_cache
    @low_camelize_factory_cache ||= {}
  end

  def self.env
    @env ||= MotionPrime::Env.new
  end

  def self.logger
    @logger ||= MotionPrime::Logger.new
  end

  def self.logger=(value)
    @logger = value
  end
end
::Prime = MotionPrime unless defined?(::Prime)