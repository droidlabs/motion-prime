module MotionPrime
  module SupportKeyValueStore
    extend ::MotionSupport::Concern

    # Key-Value accessors
    def setValue(value, forUndefinedKey: key)
      self.send(:"#{key}=", key)
    end
  end
end