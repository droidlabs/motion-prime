class AppDelegate < Prime::BaseAppDelegate
  def on_load(app, options)
    setup_navigation_styles
    open_screen HomeScreen.new(navigation: true), sidebar: SidebarScreen.new
  end

  def setup_navigation_styles
    # set navigation bar and button backgrounds
    UINavigationBar.appearance.barTintColor = Prime::Config.color.dark.uicolor
  end
end