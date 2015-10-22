FactoryGirl.define do
  key = KeyHelper.generate_key

  factory :user, class: Duse::API::Models::User do
    sequence(:username) { |n| "user#{n}" }
    email { "#{username}@example.com" }
    password "Passw0rd!"
    password_confirmation "Passw0rd!"
    public_key { key.public_key.to_s }
    private_key { key.to_s }
    confirmed_at Time.now
  end
end
