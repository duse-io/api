require "duse/api/models/folder"

FactoryGirl.define do
  factory :folder, class: Duse::API::Models::Folder do
    name "testFolder"
  end
end
