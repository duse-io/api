require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  puts 'rspec tasks could not be loaded'
end

task :routes do
  Duse::API.routes.each do |api|
    puts "#{api.route_method.ljust(8)} #{api.route_path}"
  end
end

namespace :config do
  task :check do
    require_relative 'config/environment'
    require 'duse/api'

    unless Duse::API.config.valid?
      puts Duse::API.config.errors.full_messages
    end

    unless Duse::API.config.smtp.valid?
      puts Duse::API.config.smtp.errors.full_messages
    end

    if Duse::API.config.valid? && Duse::API.config.smtp.valid?
      puts 'All configs valid'
    end
  end

  task :generate do
    require 'securerandom'

    secret_key = SecureRandom.base64(64)
    File.open '.env', 'w' do |f|
      f.write "export SECRET_KEY=\"#{secret_key}\""
      f.write "\n"
    end
  end
end

