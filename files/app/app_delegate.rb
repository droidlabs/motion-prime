class AppDelegate < Prime::BaseAppDelegate
  def on_load(app, options)
    open_screen :home, sidebar: true
  end
end