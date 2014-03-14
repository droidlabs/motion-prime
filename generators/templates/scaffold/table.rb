class <%= @p_class_name %>TableSection < Prime::TableSection
  def table_data
    <%= @s_class_name %>.all.map do |model|
      <%= @p_class_name %>CellSection.new(model: model)
    end
  end

  def on_click(table, index)
    section = data[index.row]
    screen.open_screen '<%= @p_name %>#show', params: { model: section.model }
  end
end