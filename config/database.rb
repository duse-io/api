config_dir = File.dirname(__FILE__)
ActiveRecord::Base.configurations = YAML.load(File.read(File.join(config_dir, 'database.yml')))
ActiveRecord::Base.establish_connection ENV['ENV'].to_sym
require 'duse/models/user'
require 'duse/models/secret'
require 'duse/models/secret_part'
require 'duse/models/share'

