describe Duse::API::V1::JSONSchemas::Secret do
  include JsonFactory

  it "should validate secrets correctly" do
    json = Duse::API::V1::JSONSchemas::Secret.new(default_secret)

    json.validate!(current_user: @user1)
  end
end

