# This class have some modifications for UITextField:
# * support padding, padding_left, padding_right options
# * support placeholder_color, placeholder_font options
class DMTextField < UITextField
  include MotionPrime::KeyValueStore

  attr_accessor :paddingLeft, :paddingTop, :padding,
    :placeholderColor, :placeholderFont

  # placeholder position
  def textRectForBounds(bounds)
    padding_left = self.paddingLeft || self.padding || 5
    padding_top = self.paddingTop || self.padding || 3
    CGRectInset(bounds, padding_left, padding_top)
  end

  # text position
  def editingRectForBounds(bounds)
    padding_left = self.paddingLeft || self.padding || 5
    padding_top = self.paddingTop || self.padding || 3
    CGRectInset(bounds, padding_left, padding_top)
  end

  def drawPlaceholderInRect(rect)
    color = self.placeholderColor || :gray.uicolor
    color.setFill
    font = self.placeholderFont || self.font || :system.uifont(16)
    self.placeholder.drawInRect(rect, withFont: font)
  end
end