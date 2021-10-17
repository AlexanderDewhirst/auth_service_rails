require 'rails_helper'

RSpec.describe Jwt::Authenticator, type: :service do
  subject(:clazz) { described_class.new(token: token, req: req) }

  let(:token) { nil }
  let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api"} }

  describe "#call" do
    context "with valid headers" do
      let(:user) { FactoryBot.create(:user) }

      context "with current JWT token" do
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }
        let(:token) { user_jwts[0] }

        it "authenticates the token" do
          res = clazz.call

          expect(res).to eq(user)
        end
      end

      context "with expired JWT token and valid refresh JWT token" do
        let(:payload) { { exp: 30.minutes.ago.to_i } } 
        let(:user_jwts) { Jwt::Generator.new(user: user, req: req, payload: payload).call }
        let(:token) { user_jwts[0] }

        it "refreshes and authenticates the token" do
          res = clazz.call
          
          expect(res).to be_nil
        end
      end
    end
  end

  context "with invalid headers" do
    it "returns nil" do
      res = clazz.call

      expect(res).to be_nil
    end
  end
end