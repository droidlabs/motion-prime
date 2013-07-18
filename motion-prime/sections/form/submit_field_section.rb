module MotionPrime
  class SubmitFieldSection < BaseFieldSection
    element :submit, type: :button do
      {
        styles: [
          :base_submit_button,
          :"#{form_name}_submit_button",
          :"#{form_name}_#{name}_button"
        ]
      }.merge(title: options[:title])
    end
    after_render :render_submit

    def render_submit
      view(:submit).on :touch do
        form.send(options[:action]) if options[:action]
      end
    end
  end
end