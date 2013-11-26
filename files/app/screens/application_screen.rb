class ApplicationScreen < Prime::BaseScreen
  before_load :setup_navigation

  def setup_navigation
    set_navigation_left_button 'menu', action: :show_sidebar
  end
end