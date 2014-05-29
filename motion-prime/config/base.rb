motion_require './config'
MotionPrime::Config.configure do |config|
  # MODELS
  if MotionPrime.env.test?
    config.model.store_type = :memory
  else
    config.model.store_type = :file
  end
  config.model.auto_generate_id = true

  config.api_client do |api|
    api.base = "http://example.com"
    api.client_id = ""
    api.client_secret = ""
    api.signature_secret = ""
    api.sign_request = false
    api.auth_path = '/oauth/token'
    api.api_namespace = '/api'
    api.allow_queue = false
    api.allow_cache = false
    api.default_methods_queue = [:post, :delete]
    api.default_methods_cache = [:get]
  end

  # APPEARANCE
  config.fonts do |fonts|
    fonts.base = :system
  end
  config.colors do |colors|
    colors.navigation_base = 0x1b75bc
    colors.base = 0x1b75bc
    colors.dark = 0x333333
    colors.error = 0xef471f
  end

  # SECTIONS
  config.prime.cell_section.mixins = [Prime::CellSectionMixin]

  # LOGGER
  config.logger.dealloc_items = ['screen']
  config.logger.level = :info
end