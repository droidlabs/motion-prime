module MotionPrime
  module SupportKeyValueStore
    # Key-Value accessors
    def setValue(value, forUndefinedKey: key)
      self.send(:"#{key}=", key)
    end
  end
end