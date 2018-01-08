# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

ruby '2.4.1'

gem 'cuba', '~> 3.8'
gem 'pg', '~> 0.21'
gem 'sequel', '~> 4.49'
gem 'haml', '~> 5.0'
gem 'i18n', '~> 0.8'
gem 'bcrypt', '~> 3.1'
gem 'rack-console', '~> 1.3'
gem 'bitcoin-ruby', '~> 0.0.14'
gem 'sidekiq', '~> 5.0'

group :development do
  gem 'shotgun', '~> 0.9'
end

group :development, :test do
  gem 'byebug', '~> 9.0'
  gem 'timecop', '~> 0.9'
end

group :test do
  gem 'fabrication', '~> 2.16'
  gem 'rspec', '~> 3.6'
  gem 'capybara', '~> 2.15'
  gem 'vcr', '~> 3.0'
  gem 'webmock', '~> 3.0'
end
