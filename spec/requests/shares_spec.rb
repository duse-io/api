RSpec.describe Duse::API, type: :request do
  include JsonFactory

  def app
    Duse::API::App.new
  end

  let!(:user) { FactoryGirl.create(:user) }
  let!(:share) { FactoryGirl.create(:share, user: user) }

  describe "GET /shares" do
    context "when shares exist" do
      it "returns an array of all accessible shares" do
        header "Authorization", user.create_new_token
        get "/v1/shares", "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq([{
          "id" => share.id,
          "content" => "share content",
          "signature" => "share signature",
          "last_edited_by_id" => 1,
        }])
      end
    end
  end

  describe "PUT/PATCH /shares" do
    context "when all given shares exist and are accessible to the user" do
      it "updates all given shares" do
        content, signature = user.encrypt(user.private_key, "test")
        updated_shares = [{
          id: share.id,
          content: content,
          signature: signature,
        }].to_json

        header "Authorization", user.create_new_token
        put "/v1/shares", updated_shares, "CONTENT_TYPE" => "application/json"

        share.reload
        expect(share.content).to eq content
        expect(share.signature).to eq signature
      end

      it "validates the shares"
      it "updates who last updated the share"
    end

    context "when trying to update non existing shares" do
      it "returns a bad request status code"
    end

    context "when trying to update a share the user does not own" do
      it "returns a forbidden status code"
    end
  end
end

