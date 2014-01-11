motion_require './config.rb'
MotionPrime::Config.configure do |config|
  if MotionPrime.env.test?
    config.model.store_type = :memory
  else
    config.model.store_type = :file
  end
  config.font.name = "Ubuntu"
  config.colors do |colors|
    colors.base = 0x424242
    colors.error = 0xef471f
  end
  config.api do |api|
    api.base = "http://example.com"
    api.client_id = ""
    api.client_secret = ""
  end
end