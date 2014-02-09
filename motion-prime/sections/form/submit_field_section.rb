module MotionPrime
  class SubmitFieldSection < BaseFieldSection
    element :button, type: :button do
      {title: options[:name].to_s.titleize}.merge(options[:button] || {})
    end
    element :error_message, type: :error_message, text: proc { all_errors.join("\n") if observing_errors? }

    after_render :bind_button

    def bind_button
      view(:button).on :touch do
        form.send(options[:action]) if options[:action]
      end
    end
  end
end