Prime::Config.color do |color|
  color.base = 0x3aa9b6
  color.dark = 0x41929c
end

Prime::Config.api do |api|
  api.base = "http://example.com"
  api.client_id = ""
  api.client_secret = ""
end

Prime::Config.sidebar do |sidebar|
  sidebar.background_image = "images/sidebar/bg.jpg".uiimage
end

Prime::Config.font.name = "Ubuntu"

# setup model's store
Prime::Store.connect