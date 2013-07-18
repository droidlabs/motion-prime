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

    after_render :render_button

    def render_button
      view(:button).on :touch do
        form.send(options[:action]) if options[:action]
      end
    end
  end
end