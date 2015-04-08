require 'stringio'

describe Duse::API::Endpoints::Base do
  include Rack::Test::Methods

  def app
    Duse::API::App.new
    app = Class.new(Duse::API::Endpoints::Base)
    app.get '/error' do 
      fail StandardError, 'This error should be catched'
    end
    app
  end


  it 'should log an exception to sentry when it occurs' do
    sentry_route = double
    expect(sentry_route).to receive(:call)
    faraday_adapter_stub = Proc.new do |env|
      sentry_route.call
      ['200', {}, ['']]
    end
    Raven.configuration.http_adapter = [:rack, faraday_adapter_stub]
    get '/error'
    Raven.configuration.http_adapter = nil
  end
end

