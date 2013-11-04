module MotionPrime
  module HasAuthorization
    def current_user
      App.delegate.current_user
    end
    def update_current_user
      App.delegate.update_current_user
    end
    def user_signed_in?
      current_user.present?
    end
    def api_client
      @api_client ||= ApiClient.new(access_token: current_user.try(:access_token))
    end
  end
end