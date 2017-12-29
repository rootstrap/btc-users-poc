module Routes
  class Register < Cuba
    define do
      on(get) do
        render('sessions/register', errors: {})
      end

      on(post, root, param('signup')) do |attributes|
        user = Services::Users::Create.perform(
          username: attributes['username'],
          password: attributes['password']
        )

        if user && user.valid?
          session[:user_id] = user.id

          redirect_to('/home')
        else
          res.status = 422

          render('sessions/register', errors: user.errors)
        end
      end
    end
  end
end
