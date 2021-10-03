require 'rails_helper'

RSpec.describe Jwt::Authenticator, type: :service do
  subject(:clazz) { described_class.new(headers: headers, token: token) }

  let(:headers) { {} }
  let(:token) { nil }

  describe "#call" do
    context "with valid headers" do
      let(:user) { FactoryBot.create(:user) }
      let(:headers) { { "Authorization": "Bearer " + token } }

      context "with current JWT token" do
        let(:token) { Jwt::Generator.new(user: user).call }

        it "authenticates the token" do
          res = clazz.call

          expect(res).to eq(user)
        end
      end

      context "with expired JWT token and valid refresh token" do
        let(:payload) { { exp: 30.minutes.ago.to_i } } 
        let(:token) { Jwt::Generator.new(user: user, payload: payload).call }

        it "refreshes and authenticates the token" do
          res = clazz.call
          
          expect(res).to eq(user)
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