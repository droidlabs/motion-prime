class TasksShowSection < Prime::Section
  element :title, text: proc { model.title }
end