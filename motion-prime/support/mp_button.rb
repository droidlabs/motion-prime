motion_require '../support/_key_value_store'
motion_require '../support/_padding_attribute'
class MPButton < UIButton
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute
  attr_accessor :sizeToFit

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

  def self.default_padding_left
    5
  end

  def self.default_padding_right
    5
  end

  def padding_top # to center title label
    self.paddingTop || self.padding || begin
      single_line_height = self.font.pointSize
      (self.bounds.size.height - single_line_height)/2 + 1
    end
  end

  def padding_bottom
    self.bounds.size.height - (self.font.pointSize + padding_top)
  end

  def apply_padding!(rect)
    self.setTitleEdgeInsets(padding_insets)
  end

  def apply_padding?
    super && !@custom_title_inset_drawn
  end

  def drawRect(rect)
    apply_padding(rect)
    super
  end
end