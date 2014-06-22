class MPTableView < UITableView
  def dealloc
    Prime.logger.dealloc_message :view, self.to_s
    super
  end
end