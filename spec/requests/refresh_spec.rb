require 'rails_helper'

RSpec.describe "Refresh", type: :request do
  describe "POST /api/refresh" do
    let(:token) { nil }

    context "with valid user" do
      let(:user) { FactoryBot.create(:user) }
      let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api"} }

      context "with access token" do
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }

        it "does not refresh the token" do
          post refresh_path, headers: { "Authorization" => "Bearer " + user_jwts[0] }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with valid refresh token" do
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }

        it "refreshes the token" do
          post refresh_path, headers: { "Authorization" => "Bearer " + user_jwts[1] }

          expect(response).to have_http_status :ok
        end
      end
    end
  end
end
