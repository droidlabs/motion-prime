class SidebarScreen < Prime::Screen
  def render
    @main_section = SidebarTableSection.new(screen: self)
    @main_section.render
  end

  def open_home
    app_delegate.open_screen HomeScreen.new
  end

  def open_help
    app_delegate.open_screen HelpScreen.new
  end
end