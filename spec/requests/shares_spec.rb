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
    context "when all given shares exist, are valid and are accessible to the user" do
      let!(:cipher_combo) { user.encrypt(user.private_key, "test") }
      let(:content) { cipher_combo[0] }
      let(:signature) { cipher_combo[1] }

      before :each do
        updated_shares = [{
          id: share.id,
          content: content,
          signature: signature,
        }].to_json

        header "Authorization", user.create_new_token
        put "/v1/shares", updated_shares, "CONTENT_TYPE" => "application/json"

        share.reload
      end

      it "updates the given shares" do
        expect(share.content).to eq content
        expect(share.signature).to eq signature
        expect(share.last_edited_by).to eq user
      end
    end

    context "when updated attributes are invalid" do
      it "validates and errors" do
        updated_shares = {
          id: share.id,
          content: "test",
          signature: "bad signature",
        }.to_json

        header "Authorization", user.create_new_token
        put "/v1/shares", updated_shares, "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to eq 422
      end
    end
  end
end

