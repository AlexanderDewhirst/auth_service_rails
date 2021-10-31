require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /api/login" do
    let(:params) { { users: { email: "foobar@bazboz.com", password: "testtest" } } }

    context "without user" do
      it "does not authenticate the user" do
        expect(User).to receive(:find_by_email).and_return(nil)

        post user_session_path, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with valid user" do
      let(:user) { FactoryBot.create(:user) }

      it "authenticates the user" do
        expect(User).to receive(:find_by_email).and_return(user)

        post user_session_path, params: params

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /api/validate" do
    let(:token) { nil }

    context "with valid user" do
      let(:user) { FactoryBot.create(:user) }

      context "with valid JWT token" do
        let(:req) { { "HTTP_HOST": "localhost:3000", "REQUEST_URL": "/api/validate" } }
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }

        before do
          post validate_path, headers: { "Authorization" => "Bearer " + user_jwts[0] }
        end

        it "returns a 200 response" do
          expect(response).to have_http_status :ok
        end
      end
    end
  end

  describe "DELETE /api/logout" do
    let(:token) { nil }

    context "with valid user" do
      let(:user) { FactoryBot.create(:user) }

      context "with valid JWT token" do
        let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api/sign_out"} }
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }

        before do
          delete destroy_user_session_path, headers: { "Authorization" => "Bearer " + user_jwts[0] }
        end

        it "logs the user out" do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
