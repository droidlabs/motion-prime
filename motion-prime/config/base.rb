motion_require './config.rb'
MotionPrime::Config.model do |model|
  if RUBYMOTION_ENV == 'test'
    model.store_type = :memory
  else
    model.store_type = :file
  end
end
MotionPrime::Config.font.name = "Ubuntu"
MotionPrime::Config.color do |color|
  color.base = 0x424242
  color.error = 0xef471f
end
MotionPrime::Config.api do |api|
  api.base = "http://example.com"
  api.client_id = ""
  api.client_secret = ""
end