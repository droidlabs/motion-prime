MP = MotionPrime unless defined?(MP)

MP::Config.color do |color|
  color.base = 0x3aa9b6
  color.dark = 0x41929c
end

# setup model's store
MP::Store.connect