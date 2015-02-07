describe Duse::API do
  include Rack::Test::Methods

  def app
    Rack::Cascade.new [
      Duse::API
    ]
  end

  it 'should have a route documenting all routes' do
    get '/', {}, {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_ACCEPT' => 'application/vnd.duse.1+json'
    }

    expect(last_response.status).to eq 200
    response = JSON.parse(last_response.body)
    expect(response.is_a?(Hash)).to be true
    expect(response.keys.length).to eq 2
  end

  it 'should use the api version specified in the path' do
    get '/v1', {}, {
      'CONTENT_TYPE' => 'application/json'
    }

    expect(last_response.status).to eq 200
    response = JSON.parse(last_response.body)
    expect(response.is_a?(Hash)).to be true
    expect(response.keys.length).to eq 2
  end

  it 'should not default to any api version' do
    get '/', {}, {
      'CONTENT_TYPE' => 'application/json'
    }

    expect(last_response.status).to eq 404
  end

  it 'should be possible to set the api version via a special header' do
    get '/', {}, {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_DUSE_API_VERSION' => '1'
    }

    expect(last_response.status).to eq 200
    response = JSON.parse(last_response.body)
    expect(response.is_a?(Hash)).to be true
    expect(response.keys.length).to eq 2
  end
end

