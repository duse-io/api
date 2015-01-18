class TestEndpoint < Grape::API
  get '/test_exception' do
    fail StandardError, 'Testing if this exception is catched'
  end
end

module Duse
  class API < Grape::API
    mount TestEndpoint
  end
end

describe Duse::API do
  include Rack::Test::Methods

  def app
    Duse::API
  end

  before :each do
    @log_output = StringIO.new
    app.logger Logger.new @log_output
  end

  after :each do
    app.logger Logger.new($stdout)
  end

  it 'should catch an exception and log it when it occurs' do
    get '/v1/test_exception'

    expect(last_response.status).to eq 500
    expect(last_response.body).to eq({ message: '500 Internal Server Error' }.to_json)
    expect(
      @log_output.string.include?('Testing if this exception is catched')
    ).to be true
  end
end
