module MotionPrime
  class PasswordFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end
    element :input, type: :text_field, delegate: proc { form.table_delegate } do
      {secure_text_entry: true}.merge(options[:input] || {})
    end
    element :error_message, type: :error_message, text: proc { all_errors.join("\n") if observing_errors? }
    after_render :bind_text_input
  end
end