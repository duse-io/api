module JsonFactory
  def share(user_id, raw_share, private_key, public_key)
    encrypted_share, signature = Encryption.encrypt(
        private_key, public_key, raw_share
    )
    { user_id: user_id, content: encrypted_share, signature: signature }
  end

  def default_secret(options = {})
    # allow key, user1, and user2 to be set before the method is executed
    @key   ||= KeyHelper.generate_key
    @user1 ||= FactoryGirl.create(:user, public_key: @key.public_key)
    @user2 ||= FactoryGirl.create(:user)

    {
      title: 'my secret',
      cipher_text: 'someciphertext==',
      shares: [
        share(Duse::API::Models::Server.get.id, 'share1', @key, Duse::API::Models::Server.public_key),
        share(@user1.id, 'share2', @key, @user1.public_key),
        share(@user2.id, 'share3', @key, @user2.public_key)
      ]
    }.merge(options)
  end

  def default_folder
    {
      name: 'testFolder'
    }
  end
end
