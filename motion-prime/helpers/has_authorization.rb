module MotionPrime
  module HasAuthorization
    def current_user
      App.delegate.current_user
    end
    def reset_current_user
      App.delegate.reset_current_user
    end
    def user_signed_in?
      current_user.present?
    end
    def api_client
      App.delegate.api_client
    end
  end
end