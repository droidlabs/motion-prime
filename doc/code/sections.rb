# ** What is a Section? **
#
# "Section" is something like "partial" which you may know from RubyOnRails. 
# In the first look it's just a list of elements which will be added to the "Screen".
# But the magic is inside. 
# When you add "Element" to a "Section", e.g. image or label, 
# it will try to draw it using CALayer/CGContext/etc, instead of adding new UIView.
# That way increases application speed (especially on Table elements) by 5-10 times.
#
# Let's get started.

# ** Create a section. **
#
# Just inherit it from `Prime::Section`.

class FooSection < Prime::Section
end

# ** Add some elements to the section. **
#
# Each element should have name and type: "image", "label", "button", etc. 
#
# When you send `:text` option, type will be "label" by default.
#
# When you send `:image` option, type will be "image" by default.

class FooSection < Prime::Section
  element :welcome, text: 'Hello World!'
  element :avatar, image: 'images/users/avatar.jpg'
  element :cheer, type: :button
end

# ** Render Section to Screen **
# 
# NOTE: it's recommended to use instance variables for sections, e.g. `@main_section` instead of `main_section`.

class FooScreen < Prime::Screen
  def render
    @main_section = FooSection.new(screen: self)
    @main_section.render
  end
end

# ** Add some styles for section **
# 
# Generally styles are just attributes of UIView elements.
#
# Let's style the UILabel element (:welcome label element we added above.)
#
# We send :foo parameter to `define`, because we have section named `foo` (FooSection) 
# and :welcome parameter to `style`, because the name of element is `welcome`.
#
Prime::Styles.define :foo do
  style :welcome,
    text_color: :black,
    top: 100,
    width: 320,
    left: 20,
    font: proc { :system.uifont(20) },
    size_to_fit: true,
end

# ** Next **
#
# [Read more about Models](models.html)