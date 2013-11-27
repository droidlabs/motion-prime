class AppDelegate < Prime::BaseAppDelegate
  def on_load(app, options)
    setup_navigation_styles
    open_screen HomeScreen.new(navigation: true), sidebar: SidebarScreen.new
  end

  def setup_navigation_styles
    bar_appearance = UINavigationBar.appearance
    bar_appearance.barTintColor = Prime::Config.color.dark.uicolor

    settings = {
      UITextAttributeFont =>  MP::Config.font.name.uifont(17),
      UITextAttributeTextColor =>  :white.uicolor
    }
    bar_appearance.setTitleTextAttributes(settings)
  end
end