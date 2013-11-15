module MotionPrime
  class TextFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end
    element :input, type: :text_view do
      {editable: true}.merge(options[:input] || {})
    end

    element :error_message, type: :error_message do
      {
        hidden: proc { !has_errors? },
        text: proc { observing_errors? and all_errors.join("\n") }
      }
    end
    after_render :bind_text_input
  end
end