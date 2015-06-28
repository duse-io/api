RSpec.describe Duse::API do
  include Rack::Test::Methods
  include JsonFactory

  def app
    Duse::API::App.new
  end

  before :each do
    @user = FactoryGirl.create(:user)
  end

  describe 'POST /folders' do
    it 'responds with 201 when creating' do
      folder_json = default_folder.to_json

      header 'Authorization', @user.create_new_token
      post '/v1/folders', folder_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(201)
    end

    it 'persists a new folder correctly' do
      folder_json = default_folder.to_json

      header 'Authorization', @user.create_new_token
      expect {
        post '/v1/folders', folder_json, 'CONTENT_TYPE' => 'application/json'
      }.to change{ Duse::API::Models::Folder.count }.by(1)
    end
  end

  describe 'GET /folders/:id' do
    it 'returns ok when getting' do
      folder  = FactoryGirl.create(:folder, user: @user)

      header 'Authorization', @user.create_new_token
      get "/v1/folders/#{folder.id}", 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 200
    end

    it 'nests folders when rendering' do
      first  = FactoryGirl.create(:folder, user: @user)
      second = FactoryGirl.create(:folder, user: @user, name: 'innerFolder', parent: first)

      header 'Authorization', @user.create_new_token
      get "/v1/folders/#{first.id}", 'CONTENT_TYPE' => 'application/json'

      expect(last_response.body).to eq({
        id: first.id,
        name: 'testFolder',
        subfolders: [
          {
            id: second.id,
            name: 'innerFolder',
            subfolders: [],
            secrets: [],
            url: "http://example.org/v1/folders/#{second.id}"
          }
        ],
        secrets: [],
        url: "http://example.org/v1/folders/#{first.id}"
      }.to_json)
    end
  end

  describe 'GET /folders' do
    it 'returns ok' do
      header 'Authorization', @user.create_new_token
      get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 200
    end

    it 'returns a default folder named like the user' do
      header 'Authorization', @user.create_new_token
      get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.body).to eq({
        name: @user.username,
        subfolders: [],
        secrets: []
      }.to_json)
    end

    it 'returns a default folder containing all other folders owned by the user' do
      folder = FactoryGirl.create(:folder, user: @user)

      header 'Authorization', @user.create_new_token
      get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.body).to eq({
        name: @user.username,
        subfolders: [{
          id: folder.id,
          name: 'testFolder',
          subfolders: [],
          secrets: [],
          url: "http://example.org/v1/folders/#{folder.id}"
        }],
        secrets: []
      }.to_json)
    end

    it 'puts secrets without a folder in the default folder' do
      secret = FactoryGirl.create(:secret, users: [@user])

      header 'Authorization', @user.create_new_token
      get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.body).to eq({
        name: @user.username,
        subfolders: [],
        secrets: [{
          id: secret.id,
          title: secret.title,
          url: "http://example.org/v1/secrets/#{secret.id}"
        }]
      }.to_json)
    end

    it 'correctly nests secrets' do
      folder = FactoryGirl.create(:folder, user: @user)
      secret = FactoryGirl.create(:secret, users: [@user])
      secret.user_secrets.where(user: @user).first.update(folder_id: folder.id)

      header 'Authorization', @user.create_new_token
      get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.body).to eq({
        name: @user.username,
        subfolders: [{
          id: folder.id,
          name: 'testFolder',
          subfolders: [],
          secrets: [{
            id: secret.id,
            title: secret.title,
            url: "http://example.org/v1/secrets/#{secret.id}"
          }],
          url: "http://example.org/v1/folders/#{folder.id}"
        }],
        secrets: []
      }.to_json)
    end

    it 'puts a secret in the default folder if the folder it lies in is deleted' do
      folder = FactoryGirl.create(:folder, user: @user)
      secret = FactoryGirl.create(:secret, users: [@user])
      secret.user_secrets.where(user: @user).first.update(folder_id: folder.id)
      folder.destroy

      header 'Authorization', @user.create_new_token
      get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

      expect(last_response.body).to eq({
        name: @user.username,
        subfolders: [],
        secrets: [{
          id: secret.id,
          title: secret.title,
          url: "http://example.org/v1/secrets/#{secret.id}"
        }]
      }.to_json)
    end
  end

  describe 'PUT/PATCH /folders/:id' do
    it 'returns ok' do
      folder = FactoryGirl.create(:folder, user: @user)

      header 'Authorization', @user.create_new_token
      patch "/v1/folders/#{folder.id}", { name: 'newFolderName' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 200
    end

    it 'updates the folders name' do
      folder = FactoryGirl.create(:folder, user: @user)

      header 'Authorization', @user.create_new_token
      patch "/v1/folders/#{folder.id}", { name: 'newFolderName' }.to_json, 'CONTENT_TYPE' => 'application/json'

      folder.reload
      expect(folder.name).to eq 'newFolderName'
    end
  end

  describe 'DELETE /folders/:id' do
    it 'returns no content' do
      folder = FactoryGirl.create(:folder, user: @user)

      header 'Authorization', @user.create_new_token
      delete "/v1/folders/#{folder.id}", { name: 'newFolderName' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 204
    end

    it 'deletes the folder' do
      folder = FactoryGirl.create(:folder, user: @user)

      expect {
        header 'Authorization', @user.create_new_token
        delete "/v1/folders/#{folder.id}", { name: 'newFolderName' }.to_json, 'CONTENT_TYPE' => 'application/json'
      }.to change{ Duse::API::Models::Folder.count }.by(-1)
    end
  end
end

