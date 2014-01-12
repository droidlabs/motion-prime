class MPCellWithSection < UITableViewCell
  attr_reader :section
  attr_accessor :scroll_view, :content_view 

  def setSection(section)
    # @section = section.try(:weak_ref)
    # @section_name = section.try(:name) # TODO: remove after debug
    self.content_view.setSection(section)
  end

  # def drawRect(rect)
  #   super
  #   draw_in(rect)
  # end

  # def draw_in(rect)
  #   # pp '++ drawing', @section_name, self.object_id
  #   section.draw_in(rect) if section && section.respond_to?(:draw_in)
  # end

  def initialize_content
    self.scroll_view = self.subviews.first
    scroll_view.subviews.first.removeFromSuperview
    self.content_view = MPTableViewCellContentView.alloc.initWithFrame(self.bounds)
    self.content_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.content_view.top = 0
    self.content_view.left = 0
    self.content_view.setBackgroundColor(:clear.uicolor)
    self.scroll_view.addSubview(content_view)
  end

  # def dealloc
  #   pp '--- deallog cell with section', @section_name, self.object_id
  #   super
  # end
end