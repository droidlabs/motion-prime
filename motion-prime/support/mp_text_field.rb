# This class have some modifications for UITextField:
# * support padding, padding_left, padding_right options
# * support placeholder_color, placeholder_font options
motion_require '_key_value_store'
motion_require '_padding_attribute'
motion_require '_control_content_alignment'
class MPTextField < UITextField
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute
  include MotionPrime::SupportControlContentAlignment

  attr_accessor :placeholderColor, :placeholderFont, :readonly, :placeholderAlignment

  def self.default_padding_left
    5
  end

  def self.default_padding_right
    5
  end

  # placeholder position
  def textRectForBounds(bounds)
    @_line_height = placeholder_font.pointSize
    rect = calculate_rect_for(bounds)
    @_line_height = nil
    rect
  end

  # text position
  def editingRectForBounds(bounds)
    @_line_height = self.font.pointSize
    rect = calculate_rect_for(bounds)
    @_line_height = nil
    rect
  end

  def drawPlaceholderInRect(rect)
    color = self.placeholderColor || :gray.uicolor
    color.setFill

    truncation = :tail_truncation.uilinebreakmode
    alignment = (placeholderAlignment || :left.nstextalignment)
    self.placeholder.drawInRect(rect, withFont: placeholder_font, lineBreakMode: truncation, alignment: alignment)
  end

  private
    def placeholder_font
      self.placeholderFont || self.font || :system.uifont(16)
    end

    def calculate_rect_for(bounds)
      height_diff = self.bounds.size.height - (line_height + padding_top + padding_bottom)
      bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height - height_diff)
      CGRectMake(
        bounds.origin.x + padding_left,
        bounds.origin.y + padding_top,
        bounds.size.width - (padding_left + padding_right),
        bounds.size.height - (padding_top + padding_bottom)
      )
    end
end
