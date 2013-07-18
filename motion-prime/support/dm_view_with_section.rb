class DMViewWithSection < UIView
  attr_accessor :section

  def setSection(section)
    @section = WeakRef.new(section)
  end

  def drawRect(rect)
    section.draw_in(rect)
  end
end