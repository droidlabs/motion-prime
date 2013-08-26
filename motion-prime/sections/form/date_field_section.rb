module MotionPrime
  class DateFieldSection < BaseFieldSection
    container height: 170
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
      picker.setDelegate self
      picker.setCalendar NSCalendar.alloc.initWithCalendarIdentifier NSGregorianCalendar
      picker.setDate NSDate.date, animated: true
    end
  end
end