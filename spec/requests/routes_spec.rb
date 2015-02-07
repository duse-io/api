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
      'ACCEPT' => 'application/vnd.duse.1+json'
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

  it 'should use api version 1 when none is specified by path or header' do
    get '/', {}, {
      'CONTENT_TYPE' => 'application/json'
    }

    expect(last_response.status).to eq 200
    response = JSON.parse(last_response.body)
    expect(response.is_a?(Hash)).to be true
    expect(response.keys.length).to eq 2
  end

  it 'should use api version 1 when a non existing version is requested' do
    get '/', {}, {
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/vnd.duse.2+json'
    }

    expect(last_response.status).to eq 200
    response = JSON.parse(last_response.body)
    expect(response.is_a?(Hash)).to be true
    expect(response.keys.length).to eq 2
  end
end

