class MPCellWithSection < UITableViewCell
  attr_reader :section

  def setSection(section)
    @section = section.try(:weak_ref)
    @section_name = section.name # TODO: remove after debug
  end

  def drawRect(rect)
    pp '+++ drawing sect', @section_name
    super
    draw_in(rect)
  end

  def draw_in(rect)
    return unless section
    section.draw_in(rect) if section.respond_to?(:draw_in)
  end

  def dealloc
    pp '--- deallog cell with section', @section_name
    super
  end
end