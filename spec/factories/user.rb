FactoryGirl.define do
  factory :user, class: Duse::Models::User do
    sequence(:username) { |n| "user#{n}" }
    email { "#{username}@example.com" }
    password 'Passw0rd!'
    password_confirmation 'Passw0rd!'
    public_key { KeyHelper.generate_public_key }
    confirmed_at Time.now
  end
end
