class DMButton < UIButton
  include MotionPrime::KeyValueStore
  DEFAULT_PADDING_LEFT = 5
  attr_accessor :paddingLeft, :paddingRight, :paddingTop, :padding, :sizeToFit

  def setTitle(value)
    setTitle value, forState: UIControlStateNormal
  end

  def setImage(value)
    setImage value, forState: UIControlStateNormal
  end

  def setTitleEdgeInsets(value)
    @custom_title_inset_drawn = true
    super
  end

  def padding_left
    self.paddingLeft || self.padding || DEFAULT_PADDING_LEFT
  end

  def padding_right
    self.paddingRight || padding_left || DEFAULT_PADDING_LEFT
  end

  def padding_top
    self.paddingTop || self.padding || default_padding_top
  end

  def default_padding_top # to center title label
    single_line_height = self.font.pointSize
    (self.bounds.size.height - single_line_height)/2 + 1
  end

  def drawPadding(rect)
    return if @custom_title_inset_drawn || [padding_top, padding_left, padding_right].all?(&:zero?)

    height_diff = self.bounds.size.height - (self.font.pointSize + padding_top*2)
    self.setTitleEdgeInsets UIEdgeInsetsMake(
      padding_top, padding_left,
      padding_top + height_diff, padding_right
    )
  end

  def drawRect(rect)
    drawPadding(rect)
    super
  end
end