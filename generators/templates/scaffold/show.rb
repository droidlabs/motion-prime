class <%= @p_class_name %>ShowSection < Prime::Section
  element :title, text: proc { model.title }
end