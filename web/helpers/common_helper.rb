module Helpers
  module CommonHelper
    def unprocessable!
      error!(status: 422)
    end

    def unauthorized!
      error!(status: 403)
    end

    def not_found!
      error!(status: 404)
    end

    def redirect_to(path)
      res.redirect(path)

      halt(res.finish)
    end

    def error!(status:)
      res.status = status

      halt(res.finish)
    end
  end
end
