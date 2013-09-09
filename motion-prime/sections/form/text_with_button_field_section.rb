module MotionPrime
  class TextWithButtonFieldSection < BaseFieldSection
    element :label, type: :label do
      {
        styles: [
          :base_field_label,
          :base_text_field_label,
          :"#{form_name}_field_label",
          :"#{form_name}_#{name}_field_label"
        ]
      }.merge(options[:label] || {})
    end
    element :input, type: :text_view do
      styles = [
        :base_field_input,
        :base_text_field_input,
        :"#{form_name}_field_input",
        :"#{form_name}_#{name}_field_input"
      ]
      styles << :base_field_input_with_errors if form.model && form.model.errors[name].present?

      {
        styles: styles,
        editable: true
      }.merge(options[:input] || {})
    end
    element :button, type: :button do
      {
        styles: [
          :base_text_button,
          :"#{form_name}_text_button",
          :"#{form_name}_#{name}_text_button"
        ]
      }.merge(options[:button] || {}).except(:action)
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
    after_render :bind_button_action

    def bind_button_action
      view(:button).on :touch do
        form.send(options[:button][:action])
      end if options[:button].try(:[], :action)
    end
  end
end