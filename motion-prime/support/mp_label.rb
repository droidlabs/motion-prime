class MPLabel < UILabel
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute

  def drawTextInRect(rect)
    rect = UIEdgeInsetsInsetRect(rect, padding_insets)
    super(rect)
  end
end