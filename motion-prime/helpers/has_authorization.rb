module MotionPrime
  module HasAuthorization
    def current_user
      if defined?(User) && User.respond_to?(:current)
        @current_user = User.current
      end
    end
    def user_signed_in?
      current_user.present?
    end
    def api_client
      @api_client ||= ApiClient.new(access_token: current_user.try(:access_token))
    end
  end
end