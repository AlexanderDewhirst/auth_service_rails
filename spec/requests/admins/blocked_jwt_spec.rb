require 'rails_helper'

RSpec.describe "Admin::BlockedJwt", type: :request do
  describe "POST /api/blocked_jwt" do
    context "with no auth" do
      let(:params) { { blocked_jwt: { token: nil } } }
      
      before do
        post blocked_jwt_path, params: params
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end
    
    context "with admin user" do
      let(:admin_user) { FactoryBot.create(:user, email: "admin@bazboz.com", is_admin: true) }
      let(:user) { FactoryBot.create(:user) }

      context "with current admin JWT token" do
        let(:user_jwt) { GenerateJwt.new(user: user).call }
        let(:params) { { blocked_jwt: { token: user_jwt } } }

        before do
          admin_jwt = GenerateJwt.new(user: admin_user).call
          post blocked_jwt_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end

        it { expect(response).to have_http_status :ok }
        it { expect(response.body).to eq("{\"success\":\"Successfully blocked JWT token\"}") }
        it { expect(BlockedJwt.where(token: user_jwt).count).to eq 1 }
      end

      context "with invalid admin JWT token" do
        let(:user_jwt) { GenerateJwt.new(user: user).call }
        let(:params) { { blocked_jwt: { token: user_jwt } } }

        before do
          admin_jwt = GenerateJwt.new(user: admin_user, exp: 15.minutes.ago.to_i).call
          post blocked_jwt_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end
        
        it { expect(response).to have_http_status :unauthorized }
      end

      context "with expired user JWT token" do
        let(:user_jwt) { GenerateJwt.new(user: user, exp: 15.minutes.ago.to_i).call }
        let(:params) { { blocked_jwt: { token: user_jwt } } }

        before do
          admin_jwt = GenerateJwt.new(user: admin_user).call
          post blocked_jwt_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(response.body).to eq("{\"errors\":\"Failed to block JWT token\"}") }
      end

      context "with invalid user JWT token" do
        let(:user_jwt) { "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MzI5NzIxMDksImlkIjoyMzM3fQ.Clc4Ak6B8ds5eS0oUFPhWS9TvfFdg-94k2nM90YFL3U" }
        let(:params) { { blocked_jwt: { token: user_jwt } } }

        before do
          admin_jwt = GenerateJwt.new(user: admin_user).call
          post blocked_jwt_path, headers: { "Authorization" => "Bearer " + admin_jwt }, params: params
        end

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

end
