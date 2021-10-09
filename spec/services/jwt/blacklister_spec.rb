require 'rails_helper'

RSpec.describe Jwt::Blacklister, type: :service do
  subject(:clazz) { described_class.new(token: token, user: user) }

  let(:token) { nil }
  let(:user) { nil }

  describe "#call" do
    let(:user) { FactoryBot.create(:user) }
    let(:req) { {"HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api"} }

    context "with valid JWT token" do
      let(:token) { Jwt::Generator.new(user: user, req: req).call }

      it "blacklists the token" do
        res = clazz.call

        expect(res.token).to eq(token)
        expect(BlacklistToken.where(token: token).count).to eq(1)
      end
    end

    context "with expired JWT token" do
      let(:token) { Jwt::Generator.new(user: user, req: req, payload: { exp: 1.hour.ago.to_i }).call }

      it "does not blacklist the token" do
        res = clazz.call
        
        expect(res).to be_nil
        expect(BlacklistToken.where(token: token).count).to eq(0)
      end
    end
  end
end