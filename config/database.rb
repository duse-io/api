DataMapper.setup(:default, ENV['DATABASE_URL'])
require 'models/user'
require 'models/secret'
require 'models/secret_part'
require 'models/share'
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize
