class SidebarScreen < Prime::Screen
  def render
    @main_section = SidebarTableSection.new(screen: self)
    @main_section.render
  end

  def open_home
    open_screen HomeScreen.new(navigation: true)
  end

  def open_help
    open_screen HelpScreen.new(navigation: true)
  end
end