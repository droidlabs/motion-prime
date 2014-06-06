class MPTableCellWithSection < UITableViewCell
  attr_reader :section
  attr_accessor :scroll_view, :content_view

  def setNeedsDisplay
    content_view.try(:setNeedsDisplay)
    super
  end

  def setSection(section)
    @section = section.try(:weak_ref)
    self.content_view.setSection(@section)
  end

  def initialize_content
    self.scroll_view = self.subviews.first
    # iOS 8
    if self.scroll_view.is_a?(UITableViewCellContentView)
      self.scroll_view.removeFromSuperview
      self.scroll_view = self
    else
      self.scroll_view.subviews.first.removeFromSuperview
    end
    self.content_view = MPTableViewCellContentView.alloc.initWithFrame(self.bounds)
    self.content_view.setBackgroundColor(:clear.uicolor)
    self.content_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.content_view.top = 0
    self.content_view.left = 0

    self.scroll_view.addSubview(content_view)
  end
end