module MotionPrime
  class SwitchFieldSection < BaseFieldSection
    element :label, type: :label do
      {
        styles: [
          :base_field_label,
          :base_switch_label,
          :"#{form_name}_switch_label",
          :"#{form_name}_#{name}_switch_label"
        ]
      }.merge(options[:label] || {})
    end
    element :input, type: :switch do
      {
        styles: [
          :base_field_switch,
          :"#{form_name}_field_switch",
          :"#{form_name}_#{name}_field_switch"
        ]
      }.merge(options[:input] || {})
    end
    element :hint, type: :label do
      {
        styles: [
          :base_field_label,
          :base_switch_hint,
          :"#{form_name}_switch_hint",
          :"#{form_name}_#{name}_switch_hint"
        ]
      }.merge(options[:hint] || {})
    end
  end
end