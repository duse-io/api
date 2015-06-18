source 'https://rubygems.org'

ruby '2.2.2'

gem 'bundler'
gem 'rake'
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'activerecord',  require: 'active_record'
gem 'mail'
gem 'pg'
gem 'warden'
gem 'bcrypt'
gem 'puma'
gem 'rack-cors', require: 'rack/cors'
gem 'sentry-raven', require: false

group :test do
  gem 'rspec'
  gem 'factory_girl'
  gem 'rack-test'
  gem 'climate_control'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: false
end

group :development do
  gem 'yard'
  gem 'rubocop', require: false
  gem 'foreman'
end

