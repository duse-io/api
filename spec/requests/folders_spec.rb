RSpec.describe Duse::API, type: :request do
  include JsonFactory

  def app
    Duse::API::App.new
  end

  let!(:user) { FactoryGirl.create(:user) }

  describe "POST /folders" do
    context "when provided attributes are valid" do
      it "responds with 201 when creating" do
        folder_json = default_folder.to_json

        header "Authorization", user.create_new_token
        post "/v1/folders", folder_json, "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to eq(201)
      end

      it "persists a new folder correctly" do
        folder_json = default_folder.to_json

        header "Authorization", user.create_new_token
        expect {
          post "/v1/folders", folder_json, "CONTENT_TYPE" => "application/json"
        }.to change{ Duse::API::Models::Folder.count }.by(1)
      end
    end

    context "when provided attributes are invalid" do
      it "validates and errors" do
        folder_json = { name: "???" }.to_json

        header "Authorization", user.create_new_token
        post "/v1/folders", folder_json, "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to eq(422)
      end
    end
  end

  describe "GET /folders/:id" do
    let!(:folder) { FactoryGirl.create(:folder, user: user) }
    let!(:inner_folder) { FactoryGirl.create(:folder, user: user, name: "innerFolder", parent: folder) }

    it "returns ok when getting" do
      header "Authorization", user.create_new_token
      get "/v1/folders/#{folder.id}", "CONTENT_TYPE" => "application/json"

      expect(last_response.status).to eq 200
    end

    it "nests folders when rendering" do
      header "Authorization", user.create_new_token
      get "/v1/folders/#{folder.id}", "CONTENT_TYPE" => "application/json"

      expect(last_response.body).to eq({
        id: folder.id,
        name: "testFolder",
        subfolders: [
          {
            id: inner_folder.id,
            name: "innerFolder",
            subfolders: [],
            secrets: [],
            url: "http://example.org/v1/folders/#{inner_folder.id}"
          }
        ],
        secrets: [],
        url: "http://example.org/v1/folders/#{folder.id}"
      }.to_json)
    end
  end

  describe "GET /folders" do
    it "returns ok" do
      header "Authorization", user.create_new_token
      get "/v1/folders", "CONTENT_TYPE" => "application/json"

      expect(last_response.status).to eq 200
    end

    context "when no folders exist" do
      it "returns a default folder named like the user" do
        header "Authorization", user.create_new_token
        get "/v1/folders", "CONTENT_TYPE" => "application/json"

        expect(last_response.body).to eq([{
          id: nil,
          name: user.username,
          subfolders: [],
          secrets: []
        }].to_json)
      end
    end

    context "when folders exist" do
      let!(:folder) { FactoryGirl.create(:folder, user: user) }

      it "returns a default folder containing all other folders owned by the user" do
        header "Authorization", user.create_new_token
        get "/v1/folders", "CONTENT_TYPE" => "application/json"

        expect(last_response.body).to eq([{
          id: nil,
          name: user.username,
          subfolders: [{
            id: folder.id,
            name: "testFolder",
            subfolders: [],
            secrets: [],
            url: "http://example.org/v1/folders/#{folder.id}"
          }],
          secrets: []
        }].to_json)
      end
    end

    context "when a secret is not in a folder" do
      let!(:secret) { FactoryGirl.create(:secret, users: [user]) }

      it "puts the secret in the default folder" do
        header "Authorization", user.create_new_token
        get "/v1/folders", "CONTENT_TYPE" => "application/json"

        expect(last_response.body).to eq([{
          id: nil,
          name: user.username,
          subfolders: [],
          secrets: [{
            id: secret.id,
            title: secret.title,
            url: "http://example.org/v1/secrets/#{secret.id}"
          }]
        }].to_json)
      end
    end

    context "when a secret is in a folder" do
      let!(:folder) {
        folder = FactoryGirl.create(:folder, user: user)
      }
      let!(:secret) do
        secret = FactoryGirl.create(:secret, users: [user])
        secret.user_secrets.where(user: user).first.update(folder_id: folder.id)
        secret
      end

      it "correctly nests the secret" do
        header "Authorization", user.create_new_token
        get "/v1/folders", "CONTENT_TYPE" => "application/json"

        expect(last_response.body).to eq([{
          id: nil,
          name: user.username,
          subfolders: [{
            id: folder.id,
            name: "testFolder",
            subfolders: [],
            secrets: [{
              id: secret.id,
              title: secret.title,
              url: "http://example.org/v1/secrets/#{secret.id}"
            }],
            url: "http://example.org/v1/folders/#{folder.id}"
          }],
          secrets: []
        }].to_json)
      end

      it "puts a secret in the default folder if the folder it lies in is deleted" do
        folder.destroy

        header "Authorization", user.create_new_token
        get "/v1/folders", "CONTENT_TYPE" => "application/json"

        expect(last_response.body).to eq([{
          id: nil,
          name: user.username,
          subfolders: [],
          secrets: [{
            id: secret.id,
            title: secret.title,
            url: "http://example.org/v1/secrets/#{secret.id}"
          }]
        }].to_json)
      end
    end
  end

  describe "PUT/PATCH /folders/:id" do
    context "provided attributes are valid" do
      it "returns ok" do
        folder = FactoryGirl.create(:folder, user: user)

        header "Authorization", user.create_new_token
        patch "/v1/folders/#{folder.id}", { name: "newFolderName" }.to_json, "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to eq 200
      end

      it "updates the folders name" do
        folder = FactoryGirl.create(:folder, user: user)

        header "Authorization", user.create_new_token
        patch "/v1/folders/#{folder.id}", { name: "newFolderName" }.to_json, "CONTENT_TYPE" => "application/json"

        folder.reload
        expect(folder.name).to eq "newFolderName"
      end
    end
  end

  describe "DELETE /folders/:id" do
    context "when the folder exists and the user has the right to delete it" do
      it "returns no content" do
        folder = FactoryGirl.create(:folder, user: user)

        header "Authorization", user.create_new_token
        delete "/v1/folders/#{folder.id}", { name: "newFolderName" }.to_json, "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to eq 204
      end

      it "deletes the folder" do
        folder = FactoryGirl.create(:folder, user: user)

        expect {
          header "Authorization", user.create_new_token
          delete "/v1/folders/#{folder.id}", { name: "newFolderName" }.to_json, "CONTENT_TYPE" => "application/json"
        }.to change{ Duse::API::Models::Folder.count }.by(-1)
      end
    end
  end
end

