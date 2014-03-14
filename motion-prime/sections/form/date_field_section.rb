module MotionPrime
  class DateFieldSection < BaseFieldSection
    container height: 190
    element :label, type: :label do
      default_label_options
    end
    element :input, type: :date_picker do
      options[:input] || {}
    end

    after_render :bind_input

    def bind_input
      picker = view(:input)
      picker.setDelegate form
      unless picker.date
        picker.setDate NSDate.date, animated: true
      end
      picker.on :change do
        form.send(options[:action]) if options[:action]
      end
    end

    def value
      view(:input).date
    end

    def input?
      true
    end

    def dealloc
      picker = view(:input)
      picker.setDelegate nil
      super
    end
  end
end