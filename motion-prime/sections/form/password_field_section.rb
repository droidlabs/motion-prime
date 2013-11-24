module MotionPrime
  class PasswordFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end
    element :input, type: :text_field do
      options[:input] || {}
    end
    element :error_message, type: :error_message do
      {
        hidden: proc { !has_errors? },
        text: proc { all_errors.join("\n") if observing_errors? }
      }
    end
    after_render :bind_text_input
  end
end