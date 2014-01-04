# **1. Install required tools.**
---

# * Ruby 1.9.3 or newer.
$ rvm install 2.0.0

# * RubyMotion.
Visit http://www.rubymotion.com

# **2. Create application delegate.**
#
# You should rewrite the `on_load` method, which will be runned after starting application.
#
# NOTE: you should always use AppDelegate class name.

class AppDelegate < Prime::BaseAppDelegate
  def on_load(app, options)
    open_screen :main
  end
end

# **3. Create the main screen.**
#
# You should rewrite the `render` method, which will be runned after first opening screen.
#
# NOTE: it's recommended to use instance variables for sections, e.g. `@main_section` instead of `main_section`.

class MainScreen < Prime::Screen
  title 'Main screen'

  def render
    @main_section = MyProfileSection.new(screen: self, model: User.first)
    @main_section.render
  end
end

# **4. Create your first section.**
#
# "Section" is something like helper, which contains "Elements".
#
# Each element will be added to the parent screen when you run `section.render`

class MyProfileSection < Prime::Section
  element :title, text: "Hello World"
  element :avatar, image: "images/avatar.png", type: :image
end

# **5. Create your first stylesheet file.**
#
# Styles will be applied to each element in section.
# The simplest rule by default is: `:section-name_:element-name`.
#
# E.g. if you have "MyProfileSection" (the name for section by default will be - `my_profile`)
# and "title" element, then you should use `my_profile_title` style name.

Prime::Styles.define do
  style :my_profile_title, width: 300, height: 20
end

# You can pass namespace to `define` method.

Prime::Styles.define :my_profile do
  style :title, width: 300, height: 20
end