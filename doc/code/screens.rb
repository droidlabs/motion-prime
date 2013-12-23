# ** Render the screen. **
#
# You should rewrite the `render` method of Prime::BaseScreen, which will be runned after first opening screen.

class MainScreen < Prime::BaseScreen
  def render
    @main_section = MyProfileSection.new(screen: self, model: User.first)
    @main_section.render
  end
end

# ** Set screen's title **
# 
# This title will be used in screen's navigation controller and will be shown there.

class MainScreen < Prime::BaseScreen
  title 'Main screen'
end

# Also, you can pass block to define screen's title

class MainScreen < Prime::BaseScreen
  title { params[:title] }
end

# ** Initialize screen. **
#
# Available options:
# * :navigation. when this options is true, screen will be created with navigation support, like left and right buttons and title.
# This option is false by default.

screen = MainScreen.new(navigation: true)

# ** Open screen: using app delegate. **

# Opening screen using app delegate is the most basic way, you would do it at least on app load.
#
# Available options:
# * :root. when this option is true, screen will not be in content controller and will create new root screen. 
# You can use root: true when you have already opened screen with sidebar, and you want to open new screen without sidebar.
# This option is false by default if you already have root screen and true if not.
#
# * :sidebar. send Prime::BaseScreen instance to this option if you want to create root screen with sidebar. 
# value of this options will be used as sidebar controller.

app_delegate.open_screen MainScreen.new(navigation: true), sidebar: MySidebar.new

# ** Open screen: using parent screen. **

# Opening screen using parent screen is usefull if you want to create inherited screen. 
# Parent screen should have been initialized with navigation support.

screen.open_screen AnotherScreen.new(navigation: true)

