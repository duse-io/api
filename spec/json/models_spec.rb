describe SecretJSON do
  include JsonFactory

  it 'should validate secrets correctly' do
    json = SecretJSON.new(default_secret)

    json.validate!(current_user: @user1)
  end
end

