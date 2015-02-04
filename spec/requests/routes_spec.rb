describe Duse::API do
  include Rack::Test::Methods

  def app
    Rack::Cascade.new [
      Duse::API,
      Duse::Endpoints::Routes,
      Duse::Endpoints::UserToken
    ]
  end

  it 'should have a route documenting all routes' do
    get '/v1', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 200
    response = JSON.parse(last_response.body)
    expect(response.is_a?(Hash)).to be true
    expect(response.keys.length).to eq 2
  end
end

