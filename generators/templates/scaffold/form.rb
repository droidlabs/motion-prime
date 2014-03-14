class <%= @p_class_name %>FormSection < Prime::FormSection
  field :title,
    label: { text: 'Title' },
    input: { 
      text: proc { form.model.title }, 
      placeholder: "Enter title here"
    }

  field :submit, type: :submit,
    button: { title: "Save" },
    action: :on_submit

  def on_submit
    model.assign_attributes(field_values)
    model.save
    screen.back
  end
end