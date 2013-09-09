class DMButton < UIButton
  include MotionPrime::KeyValueStore
  attr_accessor :paddingLeft, :paddingRight, :paddingTop, :padding

  def setTitle(value)
    setTitle value, forState: UIControlStateNormal
  end

  def drawPadding(rect)
    padding_left = self.paddingLeft || self.padding || 5
    padding_right = self.paddingRight || padding_left || 5
    padding_top = self.paddingTop || self.padding || 0
    self.setTitleEdgeInsets UIEdgeInsetsMake(
      padding_top, padding_left,
      padding_top, padding_right
    )
  end

  def drawRect(rect)
    drawPadding(rect)
    super
  end
end