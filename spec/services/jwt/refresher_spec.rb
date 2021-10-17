require 'rails_helper'

RSpec.describe Jwt::Refresher, type: :service do
  subject(:clazz) { described_class.new(token: token, user: user, req: req) }

  let(:token) { nil }
  let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api"} }

  describe "#call" do
    let(:user) { FactoryBot.create(:user) }
    let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api"} }

    context "with valid JWT token" do
      let(:user_jwts) { Jwt::Generator.new(user: user, req: req).call }
      let(:token) { user_jwts[1] }

      it "generates a new token" do
        res = clazz.call

        expect(res).to be_an_instance_of(Array)
        expect(res[0]).to_not eq(token)
        expect(user.refresh_tokens.count).to eq(2)
      end
    end

    context "with expired JWT token" do
      let(:user_jwts) { Jwt::Generator.new(user: user, req: req, payload: { exp: 1.hour.ago.to_i }).call }
      let(:token) { user_jwts[1] }

      it "generates a new token" do
        res = clazz.call

        expect(res).to be_an_instance_of(Array)
        expect(res[0]).to_not eq(token)
        expect(user.refresh_tokens.count).to eq(2)
      end
    end
  end
end