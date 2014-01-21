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
  config.api_client do |api|
    api.base = "http://example.com"
    api.client_id = ""
    api.client_secret = ""
    api.signature_secret = ""
    api.sign_request = false
    api.auth_path = '/oauth/token'
    api.api_namespace = '/api'
    api.request_format = :form_data
    api.allow_redirect = false
    api.allow_queue = false
  end
  config.prime.cell_section.mixins = [Prime::CellSectionMixin]
end