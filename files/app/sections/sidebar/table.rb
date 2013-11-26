class SidebarTableSection < Prime::TableSection
  def sidebar_items
    [
      {title: 'Home Screen', action: :open_home},
      {title: 'Help Screen', action: :open_help}
    ]
  end

  def table_data
    sidebar_items.map do |model|
      SidebarActionSection.new(model: model)
    end
  end

  def on_click(table, index)
    section = data[index.row]
    return false if !section || !section.model[:action]
    screen.send section.model[:action].to_sym
  end
end