# ** What is a Screen? **
#
# "Screen" is the most common class in MotionPrime, you can create entire application using only "Screens".
# Generally it's just a "UIViewController" wrapper with some syntax sugar. 
# For RubyOnRails developers the nearest analogy would be "Controllers".
---

# ** Create a screen. **
#
# Just inherit it from `Prime::Screen`.

class FooScreen < Prime::Screen
end

# ** Render the screen. **
#
# You should rewrite the `render` method of `Prime::Screen`, which will be runned after first opening screen.

class FooScreen < Prime::Screen
  def render
    @main_section = MyProfileSection.new(screen: self, model: User.first)
    @main_section.render
  end
end

# ** Set screen's title **
# 
# Title will be used in screen's navigation controller and will be shown on top of screen.
#
# NOTE: screen should be created with enabled navigation (see "Initialize screen" block).

class FooScreen < Prime::Screen
  title 'Foo screen'
end

# You can pass block to define screen's title

class FooScreen < Prime::Screen
  title { params[:title] }
end

# ** Initialize screen. **
#
# Available options:
# * `:navigation`. When this options is true, screen will be created with navigation support: it will allow adding title and left/right buttons.
# This option is true by default.

def open_foo_screen
  foo_screen = FooScreen.new(navigation: false)
end

# ** Open screen: using app delegate. **

# Opening screen using app delegate is the most basic way, you would use it at least on app load.
#
# Available options:
# * `:root`. When this option is true, screen will not be in content controller and will create new root screen. 
# You can use root: true when you have already opened screen with sidebar, and you want to open new screen without sidebar.
# This option is false by default if you already have root screen and true if not.
#
# * `:sidebar`. Send `Prime::Screen` instance to this option if you want to create root screen with sidebar. 
# Value of this options will be used as sidebar controller.

def open_foo_screen
  foo_screen = FooScreen.new
  sidebar = MySidebar.new(navigation: false)
  app_delegate.open_screen foo_screen, sidebar: sidebar
end

# ** Open screen: using parent screen. **

# Opening screen using parent screen is usefull if you want to create inherited screen. 
# Parent screen should have been initialized with navigation support.

def open_second_screen
  second_screen = SecondScreen.new(navigation: true)
  foo_screen.open_screen second_screen
end

