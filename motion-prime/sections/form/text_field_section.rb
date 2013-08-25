module MotionPrime
  class TextFieldSection < BaseFieldSection
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
      {
        styles: [
          :base_field_input,
          :base_text_field_input,
          :"#{form_name}_field_input",
          :"#{form_name}_#{name}_field_input"
        ],
        editable: true
      }.merge(options[:input] || {})
    end
    after_render :bind_text_input
  end
end