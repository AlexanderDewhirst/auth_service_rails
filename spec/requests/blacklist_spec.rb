require 'rails_helper'

RSpec.describe "Blacklist", type: :request do
  describe "POST /api/jwt/blacklist" do
    context "with no auth" do
      let(:params) { { blacklist: { token: nil } } }
      
      before do
        post blacklist_path, params: params
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
    
    context "with admin user" do
      let(:admin_user) { FactoryBot.create(:user, email: "admin@bazboz.com", is_admin: true) }
      let(:user) { FactoryBot.create(:user) }
      let(:user_jwt) { nil }
      let(:params) { { blacklist: { token: user_jwt, user_id: user.id } } }

      context "with current admin JWT token" do
        before do
          @user_jwt, _ = Jwt::Generator.new(user: user).call
          admin_jwt, _ = Jwt::Generator.new(user: admin_user).call
          params = { blacklist: { token: @user_jwt, user_id: user.id } }
          post blacklist_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end

        it { expect(response).to have_http_status :ok }
        it { expect(response.body).to eq("{\"success\":\"Successfully blacklisted JWT token\"}") }
        it { expect(BlacklistToken.where(token: @user_jwt).count).to eq 1 }
      end

      context "with invalid admin JWT token" do
        before do
          user_jwt, _ = Jwt::Generator.new(user: user).call
          admin_jwt, _ = Jwt::Generator.new(user: admin_user, payload: { exp: 15.minutes.ago.to_i }).call
          params = { blacklist: { token: user_jwt, user_id: user.id } }
          post blacklist_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end
        
        it { expect(response).to have_http_status :unauthorized }
      end

      context "with expired user JWT token" do
        before do
          user_jwt, _ = Jwt::Generator.new(user: user, payload: { exp: 15.minutes.ago.to_i }).call
          admin_jwt, _ = Jwt::Generator.new(user: admin_user).call
          params = { blacklist: { token: user_jwt, user_id: user.id } }
          post blacklist_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(response.body).to eq("{\"errors\":\"Failed to block JWT token\"}") }
      end

      context "with invalid user JWT token" do
        let(:user_jwt) { "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MzI5NzIxMDksImlkIjoyMzM3fQ.Clc4Ak6B8ds5eS0oUFPhWS9TvfFdg-94k2nM90YFL3U" }

        before do
          admin_jwt, _ = Jwt::Generator.new(user: admin_user).call
          post blacklist_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
