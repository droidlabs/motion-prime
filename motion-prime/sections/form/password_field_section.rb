module MotionPrime
  class PasswordFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end
    element :input, type: :text_field do
      options[:input] || {}
    end
    after_render :bind_text_input
  end
end