require 'rails_helper'

RSpec.describe Jwt::Revoker, type: :service do
  subject(:clazz) { described_class.new(headers: headers, user: user) }

  let(:headers) { {} }
  let(:token) { nil }
  let(:user) { nil }

  describe "#call" do
    context "with valid headers" do
      let(:user) { FactoryBot.create(:user) }
      let(:headers) { { "Authorization": "Bearer " + token } }

      context "with current JWT token" do
        let(:token) { Jwt::Generator.new(user: user).call }

        it "revokes the token and removes the refresh tokens" do
          res = clazz.call

          expect(user.refresh_tokens).to be_empty
          expect(BlacklistToken.where(token: token).count).to eq(1)
        end
      end

      context "with expired JWT token and valid refresh JWT token" do
        let(:token) { Jwt::Generator.new(user: user, payload: { exp: 30.minutes.ago.to_i }).call }

        it "removes the refesh token" do
          res = clazz.call

          expect(user.refresh_tokens).to be_empty
          expect(BlacklistToken.where(token: token).count).to eq(0)
        end
      end
    end
  end
end