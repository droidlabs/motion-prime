class DMCellWithSection < UITableViewCell
  attr_accessor :section

  def setSection(section)
    @section = section
  end

  def drawRect(rect)
    super
    section.draw_in(rect)
  end
end