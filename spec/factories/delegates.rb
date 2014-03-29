AppDelegate.send :include, MotionPrime::HasAuthorization
AppDelegate.send :include, MotionPrime::DelegateBaseMixin
AppDelegate.send :include, MotionPrime::DelegateNavigationMixin

class BaseDelegate < MotionPrime::BaseAppDelegate
  def on_load(app, options)
    self.was_loaded = true
  end
end