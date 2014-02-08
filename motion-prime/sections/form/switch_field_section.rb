module MotionPrime
  class SwitchFieldSection < BaseFieldSection
    element :label, type: :label do
      default_label_options
    end
    element :input, type: :switch do
      options[:input] || {}
    end
    element :hint, type: :label do
      options[:hint] || {}
    end
  end
end