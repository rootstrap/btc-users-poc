require 'rubygems'
require 'bundler/setup'
require 'sequel'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

require_relative 'models'
require_relative 'services'

if ENV['RACK_ENV'] == 'development'
  require 'byebug'
  require 'logger'
  DB.logger = Logger.new(STDERR)
end
