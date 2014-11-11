require_relative 'config/environment'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  puts 'rspec tasks could not be loaded'
end

task :migrate do
  require_relative 'config/database'
  DataMapper.auto_migrate!
end

task :hard_migrate do
  require_relative 'config/database'
  DataMapper.auto_upgrade!
end
