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

  describe "DELETE /api/logout" do
    let(:token) { nil }

    context "with valid user" do
      let(:user) { FactoryBot.create(:user) }

      context "with valid JWT token" do
        let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api"} }
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }

        it "logs the user out" do
          delete destroy_user_session_path, headers: { "Authorization" => "Bearer " + user_jwts[0] }

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
