module MotionPrime
  class DateFieldSection < BaseFieldSection
    container height: 190
    element :label, type: :label do
      options[:label] || {}
    end
    element :date_picker, type: :date_picker do
      options[:input] || {}
    end

    after_render :bind_date_picker

    def bind_date_picker
      picker = view(:date_picker)
      picker.setDelegate form
      unless picker.date
        picker.setDate NSDate.date, animated: true
      end
      picker.on :change do
        form.send(options[:action]) if options[:action]
      end
    end

    def dealloc
      picker = view(:date_picker)
      picker.setDelegate nil
      super
    end
  end
end