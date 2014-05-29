module MotionPrime
  class StringFieldSection < BaseFieldSection
    element :label, type: :label do
      default_label_options
    end

    element :input, type: :text_field, delegate: proc { collection_delegate } do
      options[:input] || {}
    end

    element :error_message, type: :error_message, text: proc { |field| field.all_errors.join("\n") if field.observing_errors? }
    after_element_render :input, :bind_text_input

    def value
      view(:input).text
    end

    def input?
      true
    end
  end
end