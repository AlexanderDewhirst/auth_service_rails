require 'rails_helper'

RSpec.describe Jwt::Generator, type: :service do
  subject(:clazz) { described_class.new(user: user, payload: payload) }

  let(:user) { nil }
  let(:payload) { nil }

  describe "#call" do
    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    context "with valid user" do
      let(:user) { FactoryBot.create :user }

      context "with default payload" do
        it "generates a JWT token" do
          res = clazz.call

          expect(res).to be_an_instance_of(Array)

          # Valid token
          expect(user.refresh_tokens.pluck(:id)).to include(JWT.decode(res[0], ENV["JWT_TOKEN"])[0]["refresh_id"])
          expect(JWT.decode(res[0], ENV["JWT_TOKEN"])[0]["id"]).to eq(user.id)
          expect(JWT.decode(res[0], ENV["JWT_TOKEN"])[0]["exp"]).to eq(15.minutes.from_now.to_i)

          # Valid refresh token
          expect(JWT.decode(res[1], ENV["JWT_TOKEN"])[0]["id"]).to eq(user.id)
          expect(JWT.decode(res[1], ENV["JWT_TOKEN"])[0]["exp"]).to eq(4.hours.from_now.to_i)
        end
      end

      context "with provided payload" do
        let(:payload) { { "exp": 1.hour.from_now.to_i } }

        it "generates a JWT token" do
          res = clazz.call

          expect(res).to be_an_instance_of(Array)

          # Valid token
          expect(user.refresh_tokens.pluck(:id)).to include(JWT.decode(res[0], ENV["JWT_TOKEN"])[0]["refresh_id"])
          expect(JWT.decode(res[0], ENV["JWT_TOKEN"])[0]["id"]).to eq(user.id)
          expect(JWT.decode(res[0], ENV["JWT_TOKEN"])[0]["exp"]).to eq(1.hour.from_now.to_i)

          # Valid refresh token
          expect(JWT.decode(res[1], ENV["JWT_TOKEN"])[0]["id"]).to eq(user.id)
          expect(JWT.decode(res[1], ENV["JWT_TOKEN"])[0]["exp"]).to eq(4.hours.from_now.to_i)
        end
      end
    end

    context "with invalid user" do
      it "returns nil" do
        res = clazz.call

        expect(res).to eq(nil)
      end
    end
  end
end
