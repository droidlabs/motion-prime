module MotionPrime
  class PasswordFieldSection < BaseFieldSection
    element :label, type: :label do
      {
        styles: [
          :base_field_label,
          :base_password_field_label,
          :"#{form_name}_field_label",
          :"#{form_name}_#{name}_field_label"
        ]
      }.merge(options[:label] || {})
    end
    element :input, type: :text_field do
      {
        styles: [
          :base_field_input,
          :base_password_field_input,
          :"#{form_name}_field_input",
          :"#{form_name}_#{name}_field_input"
        ],
        secureTextEntry: true
      }.merge(options[:input] || {})
    end
    after_render :render_input

    def render_input
      view(:input).on :editing_did_begin do |view|
        scroll_to_and_make_visible
        form.on_edit(self)
      end
    end
  end
end