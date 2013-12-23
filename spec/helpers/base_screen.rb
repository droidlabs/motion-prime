class BaseScreen < MotionPrime::Screen
  title "Base"
  attr_accessor :was_rendered

  def render
    self.was_rendered = true
    set_navigation_right_button "Test", action: :test, type: UIBarButtonItemStyleDone
  end
end