DataMapper.setup(:default, ENV['DATABASE_URL'])
require 'duse/models/user'
require 'duse/models/secret'
require 'duse/models/secret_part'
require 'duse/models/share'
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize
