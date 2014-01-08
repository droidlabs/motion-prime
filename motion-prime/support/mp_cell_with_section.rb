class MPCellWithSection < UITableViewCell
  attr_reader :section

  def setSection(section)
    @section = section.try(:weak_ref)
    @section_name = section.try(:name) # TODO: remove after debug
  end

  def drawRect(rect)
    super
    draw_in(rect)
  end

  def draw_in(rect)
    # pp '++ drawing', @section_name, self.object_id
    section.draw_in(rect) if section && section.respond_to?(:draw_in)
  end

  # def dealloc
  #   pp '--- deallog cell with section', @section_name, self.object_id
  #   super
  # end
end