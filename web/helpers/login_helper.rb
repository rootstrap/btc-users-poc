module Helpers
  module LoginHelper
    def require_login!
      return if current_user

      res.status = 403
      halt(res.finish)
    end

    def current_user
      return unless session[:user_id]

      @current_user ||= User.where(id: session[:user_id]).first
    end
  end
end
