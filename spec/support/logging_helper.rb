require "stringio"

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :request

  config.before :each, type: :request do
    env("rack.errors", StringIO.new)
  end
end
