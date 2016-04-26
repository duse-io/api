RSpec.describe Duse::API, type: :request do
  def app
    Duse::API::App.new
  end

  describe "GET /health-check" do
    before do
      get "/health-check"
    end

    it "returns status code 200" do
      expect(last_response.status).to eq 200
    end

    it "returns OK" do
      expect(last_response.body).to eq "OK"
    end
  end
end

