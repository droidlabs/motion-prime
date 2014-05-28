class <%= @p_class_name %>IndexTableSection < Prime::TableSection
  def collection_data
    <%= @s_class_name %>.all.map do |model|
      <%= @p_class_name %>IndexCellSection.new(model: model)
    end
  end

  def on_click(index)
    section = data[index.row]
    screen.open_screen '<%= @p_name %>#show', params: { model: section.model }
  end
end