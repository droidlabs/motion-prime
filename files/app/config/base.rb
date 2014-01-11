Prime::Config.configure do |config|
  config.colors do |colors|
    colors.base = 0x3aa9b6
    colors.dark = 0x41929c
  end

  config.font.name = "Ubuntu"

  config.api do |api|
    api.base = "http://example.com"
    api.client_id = ""
    api.client_secret = ""
  end
end