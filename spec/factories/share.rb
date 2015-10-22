require "duse/api/models/share"

FactoryGirl.define do
  factory :share, class: Duse::API::Models::Share do
    content "share content"
    signature "share signature"
    user_id 1
    secret_id 1
    last_edited_by_id 1
  end
end
