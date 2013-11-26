# This class have some modifications for UITextField:
# * support padding, padding_left, padding_right options
# * support placeholder_color, placeholder_font options
class DMTextField < UITextField
  DEFAULT_PADDING_LEFT = 5
  include MotionPrime::KeyValueStore

  attr_accessor :paddingLeft, :paddingRight, :paddingTop, :padding,
    :placeholderColor, :placeholderFont

  # placeholder position
  def textRectForBounds(bounds)
    calculate_rect_for(bounds)
  end

  # text position
  def editingRectForBounds(bounds)
    calculate_rect_for(bounds)
  end

  def drawPlaceholderInRect(rect)
    color = self.placeholderColor || :gray.uicolor
    color.setFill
    font = self.placeholderFont || self.font || :system.uifont(16)
    self.placeholder.drawInRect(rect, withFont: font)
  end

  def padding_left
    self.paddingLeft || self.padding || DEFAULT_PADDING_LEFT
  end

  def padding_right
    self.paddingRight || self.padding_left
  end

  def padding_top
    self.paddingTop || self.padding || default_padding_top
  end

  def default_padding_top # to center title label
    single_line_height = self.font.pointSize
    (self.bounds.size.height - single_line_height)/2 + 2
  end

  private
    def calculate_rect_for(bounds)
      height_diff = self.bounds.size.height - (self.font.pointSize + padding_top*2)
      bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height - height_diff)
      CGRectMake(
        bounds.origin.x + padding_left, bounds.origin.y + padding_top,
        bounds.size.width - (padding_left + padding_right), bounds.size.height - padding_top*2)
    end

end