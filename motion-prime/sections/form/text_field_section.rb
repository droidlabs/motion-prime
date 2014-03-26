module MotionPrime
  class TextFieldSection < BaseFieldSection
    element :label, type: :label do
      default_label_options
    end
    element :input, type: :text_view, delegate: proc { table_delegate } do
      {editable: true}.merge(options[:input] || {})
    end

    element :error_message, type: :error_message, text: proc { |field| field.observing_errors? and field.all_errors.join("\n") }
    after_render :bind_text_input

    def value
      view(:input).text
    end

    def input?
      true
    end
  end
end