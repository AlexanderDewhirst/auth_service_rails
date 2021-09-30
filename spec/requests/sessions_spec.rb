require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /api/login" do
    let(:params) { { users: { email:  "foobar@bazboz.com", password: "testtest" } } }
    context "with no auth" do
      before do
        post user_session_path, params: params
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context "with user" do
      let(:user) { FactoryBot.create(:user) }

      context "with current JWT token" do
        let(:jwt) { GenerateJwt.new(user: user).call }

        before do
          post user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: params
        end

        it { expect(response).to have_http_status(:ok) }
        it { expect(response.body).to eq jwt.to_json }
      end
      
      context "with expired JWT token" do
        before do
          jwt = GenerateJwt.new(user: user, exp: 15.minutes.ago.to_i ).call
          post user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: params
        end

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context "with blocked JWT token" do
        let(:blocked_jwt) { FactoryBot.create(:blocked_jwt, user: user) }

        before do
          jwt = blocked_jwt.token
          post user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: params
        end

        it { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
