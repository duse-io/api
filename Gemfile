source 'https://rubygems.org'

ruby '2.2.0'

gem 'bundler', '~> 1.6'
gem 'rake'
gem 'sinatra'
gem 'sinatra-contrib', require: false
gem 'sinatra-activerecord'
gem 'activerecord', require: 'active_record'
gem 'activesupport', require: 'active_support/all'
gem 'mail'
gem 'pg'
gem 'warden'
gem 'bcrypt'
gem 'puma'
gem 'dotenv'
gem 'rack-cors', require: 'rack/cors'
gem 'sentry-raven', require: false

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

group :development do
  gem 'yard'
  gem 'rubocop', require: false
  gem 'foreman'
end

