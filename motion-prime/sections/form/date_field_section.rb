module MotionPrime
  class DateFieldSection < BaseFieldSection
    container height: 190
    element :label, type: :label do
      {
        styles: [
          :base_field_label,
          :base_date_picker_field_label,
          :"#{form_name}_field_label",
          :"#{form_name}_#{name}_field_label"
        ]
      }.merge(options[:label] || {})
    end
    element :date_picker, type: :date_picker do
      {
        styles: [
          :base_date_picker,
          :"#{form_name}_date_picker",
          :"#{form_name}_#{name}_date_picker"
        ]
      }
    end

    after_render :bind_date_picker

    def bind_date_picker
      picker = view(:date_picker)
      picker.setDelegate form
      picker.setDate NSDate.date, animated: true
    end
  end
end