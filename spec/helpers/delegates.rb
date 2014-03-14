# motion_require '../../motion-prime/helpers/has_authorization'
# motion_require './../motion-prime/delegate/_base_mixin'
# motion_require './../motion-prime/delegate/_navigation_mixin'
AppDelegate.send :include, MotionPrime::HasAuthorization
AppDelegate.send :include, MotionPrime::DelegateBaseMixin
AppDelegate.send :include, MotionPrime::DelegateNavigationMixin

class BaseDelegate < MotionPrime::BaseAppDelegate
  def on_load(app, options)
    self.was_loaded = true
  end
end