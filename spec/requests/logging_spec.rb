describe Duse::API::App, type: :request do
  def app
    Duse::API::App.new
  end

  before :each do
    @dev = StringIO.new
    env('rack.errors', @dev)
  end

  it 'logs the access' do
    get '/'
    expect(@dev.string).to match(/log_type=HTTP_LOG timestamp=.{25} ip=127\.0\.0\.1 remote_user=- http_method=GET route=\/ http_version= response_code=404 length=18 response_time=0\.[0-9]{4}/)
  end

  context 'no errors' do
    it 'prints the audit log' do
      user = FactoryGirl.create(:user)
      token = user.create_new_token

      header 'Authorization', token
      get '/v1/secrets'

      expect(@dev.string).to match(/log_type=AUDIT_LOG timestamp=.{25} user_id=#{user.id} action=Duse::API::V1::Actions::Secret::List args={} result=success error=-\nlog_type=HTTP_LOG timestamp=.{25} ip=127\.0\.0\.1 remote_user=- http_method=GET route=\/v1\/secrets http_version= response_code=200 length=2 response_time=0\.[0-9]{4}/)
    end
  end

  context 'errors occurred' do
    it 'prints the error in the audit log' do
      user = FactoryGirl.create(:user)
      token = user.create_new_token

      header 'Authorization', token
      get '/v1/secrets/1'

      expect(@dev.string).to match(/log_type=AUDIT_LOG timestamp=.{25} user_id=#{user.id} action=Duse::API::V1::Actions::Secret::Get args={"id":"1"} result=failed error=Duse::API::NotFound\nlog_type=HTTP_LOG timestamp=.{25} ip=127\.0\.0\.1 remote_user=- http_method=GET route=\/v1\/secrets\/1 http_version= response_code=404 length=23 response_time=0\.[0-9]{4}/)
    end
  end
end

