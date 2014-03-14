class BaseScreen < MotionPrime::Screen
  title "Base"
  attr_accessor :was_rendered

  def render
    self.was_rendered = true
    set_navigation_right_button "Test", action: :test, type: UIBarButtonItemStyleDone
  end
end

class SampleScreen < MotionPrime::Screen
  title 'Sample'

  def render
    @main_section = SampleSection.new(screen: self)
    @main_section.render
  end
end