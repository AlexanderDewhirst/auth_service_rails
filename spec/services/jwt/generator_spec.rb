require 'rails_helper'

RSpec.describe Jwt::Generator, type: :service do
  subject(:clazz) { described_class.new(user: user, req: req, payload: payload) }

  let(:user) { nil }
  let(:payload) { nil }
  let(:req) { "localhost:3000/api" }

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

          access_token_decoded = JWT.decode(res[0], ENV["JWT_TOKEN"])
          refresh_token_decoded = JWT.decode(res[1], ENV["JWT_TOKEN"])
          stored_refresh_token = RefreshToken.find(access_token_decoded[0]["refresh_id"])
          stored_refresh_token_decoded = JWT.decode(stored_refresh_token.token, ENV["JWT_TOKEN"])

          expect(refresh_token_decoded).to eq(stored_refresh_token_decoded)

          # Valid token
          expect(access_token_decoded[0]["sub"]).to eq(user.id)
          expect(access_token_decoded[0]["iat"]).to eq(Time.now.to_i)
          expect(access_token_decoded[0]["exp"]).to eq(15.minutes.from_now.to_i)
          expect(access_token_decoded[0]["iss"]).to eq("localhost:3000/api")

          # Valid refresh token
          expect(refresh_token_decoded[0]["sub"]).to eq(user.id)
          expect(refresh_token_decoded[0]["iat"]).to eq(Time.now.to_i)
          expect(refresh_token_decoded[0]["exp"]).to eq(4.hours.from_now.to_i)
          expect(refresh_token_decoded[0]["iss"]).to eq("localhost:3000/api")
        end
      end

      context "with provided payload" do
        let(:payload) { { "exp": 1.hour.from_now.to_i } }

        it "generates a JWT token" do
          res = clazz.call

          access_token_decoded = JWT.decode(res[0], ENV["JWT_TOKEN"])
          refresh_token_decoded = JWT.decode(res[1], ENV["JWT_TOKEN"])
          stored_refresh_token = RefreshToken.find(access_token_decoded[0]["refresh_id"])
          stored_refresh_token_decoded = JWT.decode(stored_refresh_token.token, ENV["JWT_TOKEN"])

          expect(refresh_token_decoded).to eq(stored_refresh_token_decoded)

          # Valid token
          expect(access_token_decoded[0]["sub"]).to eq(user.id)
          expect(access_token_decoded[0]["iat"]).to eq(Time.now.to_i)
          expect(access_token_decoded[0]["exp"]).to eq(1.hour.from_now.to_i)
          expect(access_token_decoded[0]["iss"]).to eq("localhost:3000/api")

          # Valid refresh token
          expect(refresh_token_decoded[0]["sub"]).to eq(user.id)
          expect(refresh_token_decoded[0]["iat"]).to eq(Time.now.to_i)
          expect(refresh_token_decoded[0]["exp"]).to eq(4.hours.from_now.to_i)
          expect(refresh_token_decoded[0]["iss"]).to eq("localhost:3000/api")
        end
      end
    end

    context "with invalid user" do
      it "returns nil" do
        res = clazz.call

        expect(res).to be_nil
      end
    end
  end
end
