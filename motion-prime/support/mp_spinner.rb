class MPSpinner < MBRoundProgressView
  def init_animation
    return if @firstTimestamp
    displayLink = CADisplayLink.displayLinkWithTarget(self, selector: :"handleDisplayLink:")
    displayLink.addToRunLoop(NSRunLoop.currentRunLoop, forMode: NSDefaultRunLoopMode)
  end

  def handleDisplayLink(displayLink)
    @firstTimestamp ||= displayLink.timestamp
    elapsed = (displayLink.timestamp - @firstTimestamp)
    rotate(elapsed)
  end

  def rotate(angle)
    self.layer.transform = CATransform3DMakeRotation((Math::PI * 2) * angle, 0, 0, 1)
  end
end