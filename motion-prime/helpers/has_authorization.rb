module MotionPrime
  module HasAuthorization
    def current_user
      @current_user = User.current
    end
    def api_client
      @api_client ||= ApiClient.new(access_token: current_user.access_token)
    end
  end
end