require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /" do
    context "with no auth" do
      before do
        post api_user_session_path, params: { users: { email: "foobar@bazboz.com", password: "testtest"} }
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context "with current JWT token" do
      let(:user) { FactoryBot.create(:user) }
      let(:jwt) { GenerateJwt.new(user: user).call }

      before do
        post api_user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: { users: { email: "foobar@bazboz.com", password: "testtest"} }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.body).to eq jwt.to_json }
    end
    
    context "with expired JWT token" do
      let(:user) { FactoryBot.create(:user) }

      before do
        jwt = GenerateJwt.new(user: user, exp: 15.minutes.ago.to_i ).call
        post api_user_session_path, headers: { "Authorization" => "Bearer " + jwt }, params: { users: { email: "foobar@bazboz.com", password: "testtest"} }
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end
end
