# Search bar with background and no padding
class UISearchBarCustom < UISearchBar
  def layoutSubviews
    super
    text_field = subviews.objectAtIndex(0).subviews.detect do |view|
      view.is_a?(UISearchBarTextField)
    end
    text_field.frame = CGRectMake(0, 0, 320, 44)
  end
end