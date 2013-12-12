# This class have some modifications for UITextView:
# * support padding, padding_left, padding_right options
# * support placeholder, placeholder_color, placeholder_font options
class MPTextView < UITextView
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
    self.textContainer.lineFragmentPadding = 0 # left/right
    self.textContainerInset = self.padding_insets
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