module MotionPrime
  def self.env
    ENV['PRIME_ENV'] || ENV['RUBYMOTION_ENV'] || 'development'
  end

  def self.root
    File.expand_path File.dirname(__FILE__) + '/../'
  end
end
::Prime = MotionPrime unless defined?(::Prime)