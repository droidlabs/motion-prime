class MPLabel < UILabel
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute

  def drawTextInRect(rect)
    insets = UIEdgeInsetsMake(padding_top, padding_left, padding_bottom, padding_right)
    rect = UIEdgeInsetsInsetRect(rect, insets)
    super(rect)
  end
end