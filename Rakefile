require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative 'config/environment'
    require 'duse/api'
  end
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  puts 'rspec tasks could not be loaded'
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

  task :secret do
    require 'securerandom'

    secret_key = SecureRandom.base64(64)
    puts secret_key
  end
end

task :exchange_server_keypair => 'db:load_config' do
  server_user = Duse::API::Models::Server.get
  old_keypair = server_user.private_key
  new_keypair = OpenSSL::PKey::RSA.generate(4096)
  server_user.private_key = new_keypair.to_s
  server_user.public_key = new_keypair.public_key.to_s
  server_user.save
  shares = Duse::API::Models::Share.where(user: server_user)
  shares.each do |share|
    plaintext = Encryption.decrypt old_keypair, share.content
    share.content, share.signature = Encryption.encrypt new_keypair, new_keypair.public_key, plaintext
    share.save
  end
end

task :make_admin, [:id] => ['db:load_config'] do |t, args|
  if Duse::API::Models::User.exists? args.id
    user = Duse::API::Models::User.find(args.id)
    user.update(admin: true)
    puts "User with ID #{args.id} is now an admin."
  else
    puts "User with ID #{args.id} does not exist."
  end
end

