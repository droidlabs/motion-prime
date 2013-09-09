module MotionPrime
  class StringFieldSection < BaseFieldSection
    element :label, type: :label do
      {
        styles: [
          :base_field_label,
          :base_string_field_label,
          :"#{form_name}_field_label",
          :"#{form_name}_#{name}_field_label"
        ]
      }.merge(options[:label] || {})
    end

    element :input, type: :text_field do
      styles = [
        :base_field_input,
        :base_string_field_input,
        :"#{form_name}_field_input",
        :"#{form_name}_#{name}_field_input"
      ]
      styles << :base_field_input_with_errors if form.model && form.model.errors[name].present?
      {styles: styles}.merge(options[:input] || {})
    end

    element :error_message, type: :error_message do
      {
        styles: [
          :base_field_label,
          :base_string_field_label,
          :"#{form_name}_field_label",
          :"#{form_name}_#{name}_field_label",
          :base_error_message
        ],
        hidden: proc { form.model && form.model.errors[name].blank? },
        text: proc { form.model and form.model.errors[name].join("\n") }
      }
    end
    after_render :bind_text_input
  end
end