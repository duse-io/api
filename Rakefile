require_relative 'config/environment'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  puts 'rspec tasks could not be loaded'
end

task :env do
  require 'openssl'
  require 'securerandom'
  key = OpenSSL::PKey::RSA.generate(1024)
  public_key = key.public_key.to_s
  private_key = key.to_pem
  password = SecureRandom.base64(32)
  File.open('.env', 'w') do |file|
    file.puts("export PUBLIC_KEY=#{public_key.inspect}")
    file.puts("export PRIVATE_KEY=#{private_key.inspect}")
    file.puts("export PASSWORD=#{password.inspect}")
  end
end

task :migrate do
  require_relative 'config/database'
  DataMapper.auto_migrate!
end

task :create do
  require_relative 'config/database'
  require 'pg'
  require 'uri'

  uri = URI(ENV['DATABASE_URL'])
  host = uri.host
  dbname = uri.path[1, uri.path.length]
  conn = PG.connect(dbname: 'postgres', host: host, user: 'postgres')
  dbexists = false
  conn.exec("SELECT EXISTS ( SELECT * FROM pg_catalog.pg_database WHERE lower(datname) = lower('#{dbname}') );") do |result|
    result.each do |row|
      dbexists = row['exists'] == 't'
    end
  end
  unless dbexists
    conn.exec("CREATE DATABASE #{dbname}")
  end
end

task :drop do
  require_relative 'config/database'
  require 'pg'
  require 'uri'

  uri = URI(ENV['DATABASE_URL'])
  host = uri.host
  dbname = uri.path[1, uri.path.length]
  conn = PG.connect(dbname: 'postgres', host: host, user: 'postgres')
  dbexists = false
  conn.exec("SELECT EXISTS ( SELECT * FROM pg_catalog.pg_database WHERE lower(datname) = lower('#{dbname}') );") do |result|
    result.each do |row|
      dbexists = row['exists'] == 't'
    end
  end
  if dbexists
    conn.exec("DROP DATABASE #{dbname}")
  end
end
