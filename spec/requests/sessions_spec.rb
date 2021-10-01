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
        let(:jwt) { Jwt::Generator.new(user: user).call }

        before do
          post user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: params
        end

        it { expect(response).to have_http_status(:ok) }
        it { expect(response.body).to eq jwt.to_json }
      end
      
      context "with expired JWT token" do
        before do
          jwt = Jwt::Generator.new(user: user, payload: { exp: 15.minutes.ago.to_i }).call
          post user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: params
        end

        it { expect(response).to have_http_status(:unauthorized) }
      end

      context "with blacklisted JWT token" do
        let(:blacklisted_jwt) { FactoryBot.create(:blacklist_token, user: user) }

        before do
          jwt = blacklisted_jwt.token
          post user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: params
        end

        it { expect(response).to have_http_status(:unauthorized) }
      end
    end
  end
end
