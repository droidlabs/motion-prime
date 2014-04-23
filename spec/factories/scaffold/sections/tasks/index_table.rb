class TasksIndexTableSection < Prime::TableSection
  def table_data
    Task.all.map do |model|
      TasksIndexCellSection.new(model: model)
    end
  end

  def on_click(index)
    section = data[index.row]
    screen.open_screen 'tasks#show', params: { model: section.model }
  end
end