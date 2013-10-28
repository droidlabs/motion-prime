module MotionPrime
  class StringFieldSection < BaseFieldSection
    element :label, type: :label do
      options[:label] || {}
    end

    element :input, type: :text_field do
      options[:input] || {}
    end

    element :error_message, type: :error_message do
      {
        hidden: proc { form.model && form.model.errors[name].blank? },
        text: proc { form.model and form.model.errors[name].join("\n") }
      }
    end
    after_render :bind_text_input
  end
end