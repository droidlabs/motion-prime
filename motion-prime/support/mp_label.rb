motion_require '../support/_key_value_store'
motion_require '../support/_padding_attribute'
class MPLabel < UILabel
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute

  def drawTextInRect(rect)
    rect = UIEdgeInsetsInsetRect(rect, padding_insets)
    super(rect)
  end
end