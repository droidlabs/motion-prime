# This class have some modifications for UITextView:
# * support padding, padding_left, padding_right options
# * support placeholder, placeholder_color, placeholder_font options
class DMTextView < UITextView
  include MotionPrime::SupportKeyValueStore
  include MotionPrime::SupportPaddingAttribute
  attr_accessor :placeholderColor, :placeholderFont, :placeholder

  def self.default_padding_left
    5
  end

  def self.default_padding_right
    5
  end

  def drawPadding(rect)
    # add padding to UITextView
    padding_left = self.padding_left - 5
    padding_top = self.padding_top - 8
    padding = UIEdgeInsetsMake(
      padding_top, padding_left,
      padding_bottom, padding_right
    )
    self.contentInset = padding

    # must change frame before bounds because the text wrap is reformatted based on frame,
    # don't include the top and bottom insets
    insetFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0, padding.left, 0, padding.right))
    # offset frame back to original x
    offsetX = frame.origin.x - (insetFrame.origin.x - ( padding.left + padding.right ) / 2)
    insetFrame = CGRectApplyAffineTransform(insetFrame, CGAffineTransformMakeTranslation(offsetX, 0))
    self.frame = insetFrame
    self.bounds = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, -padding.left, 0, -padding.right))
  end

  def drawPlaceholder(rect)
    padding = UIEdgeInsetsMake(
      padding_top, padding_left,
      padding_bottom, padding_right
    )
    if self.placeholder && self.text.blank?
      color = self.placeholderColor || :gray.uicolor
      color.setFill
      font = self.placeholderFont || self.font || :system.uifont(16)

      color.setFill
      rect = CGRectMake(
        rect.origin.x + padding_left,
        rect.origin.y + padding_top,
        self.frame.size.width - padding_left,
        self.frame.size.height - padding_top
      )
      placeholder.drawInRect(rect, withFont: font)
    end
  end

  def drawRect(rect)
    drawPadding(rect)
    drawPlaceholder(rect)
    super
  end

  def initPlaceholder
    NSNotificationCenter.defaultCenter.addObserver(self,
      selector: :textChanged, name: UITextViewTextDidChangeNotification, object: self
    )
    @shouldDrawPlaceholder = placeholder && self.text.blank?
  end

  def textChanged
    updatePlaceholderDraw
  end

  def updatePlaceholderDraw
    prev = @shouldDrawPlaceholder
    @shouldDrawPlaceholder = placeholder && self.text.blank?
    if prev != @shouldDrawPlaceholder
      self.setNeedsDisplay
    end
  end

  # custom initializer
  def initWithCoder(aDecoder)
    if super
      initPlaceholder
    end
    self
  end

  def initWithFrame(frame)
    if super
      initPlaceholder
    end
    self
  end
end