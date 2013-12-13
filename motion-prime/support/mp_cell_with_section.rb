class MPCellWithSection < UITableViewCell
  attr_accessor :section

  def setSection(section)
    @section = section
  end

  def drawRect(rect)
    super
    section.draw_in(rect) if section.respond_to?(:draw_in)
  end
end