module MotionPrime
  class SubmitFieldSection < BaseFieldSection
    element :submit, type: :button do
      {title: options[:title]}
    end
    after_render :bind_submit

    def bind_submit
      view(:submit).on :touch do
        form.send(options[:action]) if options[:action]
      end
    end

    def events_off
      view(:submit).off :touch
    end
  end
end