class MPViewWithSection < UIView
  attr_accessor :section

  def setSection(section)
    @section = section.try(:weak_ref)
  end

  def drawRect(rect)
    section.draw_in(rect)
  end
end