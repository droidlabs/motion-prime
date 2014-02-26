class MPTableHeaderWithSectionView < UITableViewHeaderFooterView
  attr_accessor :section, :selection_style

  def setSection(section)
    @section = section.try(:weak_ref)
  end

  def drawRect(rect)
    section.try(:draw_in, rect)
    super
  end
end