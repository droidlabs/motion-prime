class <%= @p_class_name %>CellSection < Prime::Section
  container height: 40
  element :title, text: proc { model.title }
end