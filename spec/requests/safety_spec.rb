class TestEndpoint < Sinatra::Base
  get '/v1/test_exception' do
    fail StandardError, 'Testing if this exception is catched'
  end
end

describe Duse::API do
  include Rack::Test::Methods

  def app
    Duse::API
  end

  xit 'should catch an exception and log it when it occurs' do
    log_output = StringIO.new
    app.use TestEndpoint

    get '/v1/test_exception'

    expect(last_response.status).to eq 500
    expect(
      log_output.string.include?('Testing if this exception is catched')
    ).to be true
  end
end

