motion_require './config.rb'
MotionPrime::Config.model do |model|
  if RUBYMOTION_ENV == 'test'
    model.store_type = :memory
  else
    model.store_type = :file
  end
end