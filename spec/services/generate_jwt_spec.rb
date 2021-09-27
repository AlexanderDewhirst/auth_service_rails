require 'rails_helper'

RSpec.describe GenerateJwt, type: :service do
  subject(:clazz) { described_class.new(user: user) }

  let(:user) { FactoryBot.build :user }

  describe "#call" do
    context "with valid user" do
      it "generates a JWT token" do
        res = clazz.call

        expect(res).to be_an_instance_of(String)
        expect(res.length).to eq 103
      end
    end
  end
end
