class SidebarScreen < Prime::BaseScreen
  def render
    @main_section = SidebarTableSection.new()
    @main_section.render(to: self)
  end

  def open_home
    open_screen HomeScreen.new(navigation: true)
  end

  def open_help
    open_screen HelpScreen.new(navigation: true)
  end
end