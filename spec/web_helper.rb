require 'spec_helper'
require_relative 'support/web'

require 'rack/test'
require './web/server'

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Support::Web)
end
