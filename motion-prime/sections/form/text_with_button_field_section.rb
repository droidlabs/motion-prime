module MotionPrime
  class TextWithButtonFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end
    element :input, type: :text_view do
      {editable: true}.merge(options[:input] || {})
    end
    element :button, type: :button do
      (options[:button] || {}).except(:action)
    end
    element :error_message, type: :error_message do
      {
        hidden: proc { !has_errors? },
        text: proc { observing_errors? and all_errors.join("\n") }
      }
    end

    after_render :bind_text_input
    after_render :bind_button_action

    def bind_button_action
      view(:button).on :touch do
        form.send(options[:button][:action])
      end if options[:button].try(:[], :action)
    end
  end
end