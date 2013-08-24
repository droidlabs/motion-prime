class DMViewWithSection < UIView
  attr_accessor :section

  def setSection(section)
    @section = section
  end

  def drawRect(rect)
    section.draw_in(rect)
  end
end