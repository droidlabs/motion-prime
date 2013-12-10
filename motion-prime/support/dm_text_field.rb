# This class have some modifications for UITextField:
# * support padding, padding_left, padding_right options
# * support placeholder_color, placeholder_font options
class DMTextField < UITextField
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute
  attr_accessor :placeholderColor, :placeholderFont, :readonly


  def self.default_padding_left
    5
  end

  def self.default_padding_right
    5
  end

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

  def padding_top # to center title label
    self.paddingTop || self.padding || begin
      single_line_height = self.font.pointSize
      (self.bounds.size.height - single_line_height)/2 + 1
    end
  end

  private
    def calculate_rect_for(bounds)
      height_diff = self.bounds.size.height - (self.font.pointSize + padding_top + padding_bottom)
      bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height - height_diff)
      CGRectMake(
        bounds.origin.x + padding_left, bounds.origin.y + padding_top,
        bounds.size.width - (padding_left + padding_right), bounds.size.height - (padding_top + padding_bottom))
    end
end