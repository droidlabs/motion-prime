class HomeScreen < ApplicationScreen
  title 'Home'

  def render
    @main_section = HomeSection.new(screen: self)
    @main_section.render
  end
end