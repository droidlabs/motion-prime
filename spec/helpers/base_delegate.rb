class BaseDelegate < MotionPrime::BaseAppDelegate
  def on_load(app, options)
    self.was_loaded = true
  end
end