require 'rails_helper'

RSpec.describe Jwt::Refresher, type: :service do
  subject(:clazz) { described_class.new(token: token) }

  let(:token) { nil }

  describe "#call" do
    let(:user) { FactoryBot.create(:user) }

    context "with valid JWT token" do
      let(:token) { Jwt::Generator.new(user: user).call }

      it "generates a new token" do
        res = clazz.call

        expect(res).to be_an_instance_of(String)
        expect(res).to_not eq(token)
        expect(user.refresh_tokens.count).to eq(2)
      end
    end

    context "with expired JWT token" do
      let(:token) { Jwt::Generator.new(user: user, payload: { exp: 1.hour.ago.to_i }).call }

      it "generates a new token" do
        res = clazz.call

        expect(res).to be_an_instance_of(String)
        expect(res).to_not eq(token)
        expect(user.refresh_tokens.count).to eq(2)
      end
    end
  end
end