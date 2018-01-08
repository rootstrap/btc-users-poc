require 'cuba'
require 'cuba/safe'
require 'cuba/render'
require 'i18n'

Cuba.use(Rack::Session::Cookie, secret: ENV['RACK_SESSION_SECRET'])
Cuba.plugin(Cuba::Safe)
Cuba.plugin(Cuba::Render)

Cuba.settings[:render][:template_engine] = 'haml'
Cuba.settings[:render][:views] = './web/views'
Cuba.settings[:render][:layout] = 'layout'

I18n.load_path = [['./web/locales/en.yml']]
I18n.locale = :en

require_relative 'helpers/login_helper'
require_relative 'helpers/common_helper'
require_relative 'helpers/api_helper'
require_relative 'helpers/btc_helper'

Cuba.plugin(Helpers::LoginHelper)
Cuba.plugin(Helpers::CommonHelper)
Cuba.plugin(Helpers::APIHelper)
Cuba.plugin(Helpers::BTCHelper)

require './app/application'
require './app/workers'
require_relative 'routes/sessions'
require_relative 'routes/register'
require_relative 'routes/user'
require_relative 'routes/callbacks'

Cuba.define do
  on('callbacks') { run(Routes::Callbacks) }

  on csrf.unsafe? do
    csrf.reset!

    res.status = 403
    res.write('Not authorized')
    halt(res.finish)
  end

  on(root) do
    if current_user
      redirect_to('/home')
    else
      redirect_to('/sessions/new')
    end
  end

  on('user') { run(Routes::User) }
  on('sessions') { run(Routes::Sessions) }
  on('register') { run(Routes::Register) }
  on('home') { render('home') }

  run(Rack::File.new('./public'))
end
