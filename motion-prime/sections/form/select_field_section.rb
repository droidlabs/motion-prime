module MotionPrime
  class SelectFieldSection < BaseFieldSection
    element :label, type: :label do
      {
        styles: [
          :base_field_label,
          :base_select_field_label,
          :"#{form_name}_field_label",
          :"#{form_name}_#{name}_field_label"
        ]
      }.merge(options[:label] || {})
    end
    element :button, type: :button do
      {
        styles: [
          :base_select_field_button,
          :"#{form_name}_field_button",
          :"#{form_name}_#{name}_field_button"
        ],
      }.merge(options[:button] || {})
    end
    element :arrow, type: :image do
      {
        styles: [
          :base_select_field_arrow,
          :"#{form_name}_field_arrow",
          :"#{form_name}_#{name}_field_arrow"
        ],
      }.merge(options[:arrow] || {})
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

    after_render :bind_select_button

    def bind_select_button
      view(:button).on :touch do
        form.send(options[:action]) if options[:action]
      end
    end
  end
end