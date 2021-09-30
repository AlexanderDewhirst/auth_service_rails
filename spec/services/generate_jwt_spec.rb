require 'rails_helper'

RSpec.describe GenerateJwt, type: :service do
  subject(:clazz) { described_class.new(user: user) }

  describe "#call" do
    context "with valid user" do
      let(:user) { FactoryBot.build :user }

      it "generates a JWT token" do
        res = clazz.call

        expect(res).to be_an_instance_of(String)
        expect(res.length).to eq 103
      end
    end

    context "with invalid user" do
      let(:user) { nil }

      it "returns nil" do
        res = clazz.call

        expect(res).to eq(nil)
      end
    end
  end
end
