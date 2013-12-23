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
---

# ** Create a section. **
#
# Just inherit it from `Prime::Section`.

class FooSection < Prime::Section
end

# ** Add some elements to the section. **
#
# Each element should have name and type: "image", "label", "button", etc. 
# When you send `:text` option, type will be "label" by default.
# When you send `:image` option, type will be "image" by default.

class FooSection < Prime::Section
  element :welcome, text: 'Hello World!'
  element :avatar, image: 'images/users/avatar.jpg'
  element :cheer, type: :button
end

# ** Render Section in Screen **
# 
# NOTE: You must send "screen" option on section initialization.

class FooScreen < Prime::Screen
  def render
    @main_section = FooSection.new(screen: self)
    @main_section.render
  end
end
