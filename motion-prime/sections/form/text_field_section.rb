module MotionPrime
  class TextFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end
    element :input, type: :text_view do
      {editable: true}.merge(options[:input] || {})
    end

    element :error_message, type: :error_message, text: proc { observing_errors? and all_errors.join("\n") }
    after_render :bind_text_input

    def events_off
      view(:input).off :change
    end
  end
end