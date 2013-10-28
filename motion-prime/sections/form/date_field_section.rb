module MotionPrime
  class DateFieldSection < BaseFieldSection
    container height: 190
    element :label, type: :label do
      options[:label] || {}
    end
    element :date_picker, type: :date_picker

    after_render :bind_date_picker

    def bind_date_picker
      picker = view(:date_picker)
      picker.setDelegate form
      picker.setDate NSDate.date, animated: true
    end
  end
end