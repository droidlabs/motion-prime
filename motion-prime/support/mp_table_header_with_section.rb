class MPTableHeaderWithSectionView < UITableViewHeaderFooterView
  attr_accessor :section, :selection_style, :content_view

  def setSection(section)
    @section = section.try(:weak_ref)
    self.content_view.setSection(@section)
  end

  def setNeedsDisplay
    content_view.try(:setNeedsDisplay)
    super
  end

  def initialize_content
    self.content_view = MPTableViewCellContentView.alloc.initWithFrame(self.bounds)
    self.content_view.setBackgroundColor(:clear.uicolor)
    self.content_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.content_view.top = 0
    self.content_view.left = 0

    self.addSubview(content_view)
  end
end