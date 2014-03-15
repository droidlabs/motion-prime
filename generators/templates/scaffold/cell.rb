class <%= @p_class_name %>IndexCellSection < Prime::Section
  container height: 40
  element :title, text: proc { model.title }
end