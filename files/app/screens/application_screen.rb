class ApplicationScreen < Prime::Screen
  before_load :setup_navigation

  def setup_navigation
    set_navigation_left_button 'menu', image: 'images/menu_button.png', action: :toggle_sidebar
  end
end