motion_require '_key_value_store'
motion_require '_padding_attribute'
motion_require '_control_content_alignment'
class MPButton < UIButton
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute
  include MotionPrime::SupportControlContentAlignment

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