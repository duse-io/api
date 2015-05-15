require 'support/key_helper'

FactoryGirl.define do
  factory :secret, class: Duse::Models::Secret do
    key = KeyHelper.generate_key
    last_edited_by { create(:user, public_key: key.public_key.to_s) }
    sequence(:title) { |n| "secret#{n}" }
    cipher_text 'someciphertext=='

    shares do |shares|
      server = Duse::Models::Server.get
      other_user = create(:user)
      server_content, server_signature = Encryption.encrypt(key, server.public_key, 'share1')
      user_content, user_signature = Encryption.encrypt(key, last_edited_by.public_key, 'share2')
      other_user_content, other_user_signature = Encryption.encrypt(key, other_user.public_key, 'share3')
      [
        shares.association(:share, user: server, content: server_content, signature: server_signature),
        shares.association(:share, user: last_edited_by, content: user_content, signature: user_signature),
        shares.association(:share, user: other_user, content: other_user_content, signature: other_user_signature)
      ]
    end
  end
end
