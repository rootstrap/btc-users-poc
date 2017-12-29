module Routes
  class Sessions < Cuba
    define do
      on(get, 'new') do
        render('sessions/new', errors: {})
      end

      on(post, root, param('signin')) do |attributes|
        user = Services::Users::Signin.perform(
          attributes['username'],
          attributes['password']
        )

        if user
          session[:user_id] = user.id

          redirect_to('/home')
        else
          res.status = 422

          render('sessions/new', errors: {username: [:invalid]})
        end
      end

      on(post, 'delete') do
        session.delete(:user_id)
        redirect_to('/sessions/new')
      end
    end
  end
end
