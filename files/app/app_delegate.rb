class AppDelegate < Prime::BaseAppDelegate
  def on_load(app, options)
    setup_navigation_styles
    open_with_sidebar HomeScreen.new(navigation: true), SidebarScreen.new
  end

  def setup_navigation_styles
    # set navigation bar and button backgrounds
    UINavigationBar.appearance.setBackgroundImage "images/navigation/bg.png".uiimage,
      forBarMetrics: UIBarMetricsDefault
    UIBarButtonItem.appearance.setBackgroundImage "images/navigation/button.png".uiimage,
      forState: UIControlStateNormal, barMetrics:UIBarMetricsDefault
  end
end