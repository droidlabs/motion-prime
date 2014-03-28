motion_require '../helpers/has_authorization'
motion_require './_base_mixin'
motion_require './_navigation_mixin'
module MotionPrime
  class BaseAppDelegate
    include HasAuthorization
    include DelegateBaseMixin
    include DelegateNavigationMixin

    def on_apn_register_success(application, token)
    end

    def on_apn_register_fail(application, error)
    end

    def current_user
      @current_user ||= if defined?(User) && User.respond_to?(:current)
        User.current
      end
    end

    def reset_current_user
      user_was = @current_user
      @current_user = nil
      NSNotificationCenter.defaultCenter.postNotificationName(:on_current_user_reset, object: user_was)
    end

    def api_client
      @api_client ||= ApiClient.new(access_token: current_user.try(:access_token))
    end
  end
end