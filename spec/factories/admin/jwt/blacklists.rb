FactoryBot.define do
  factory :blacklist_token, class: BlacklistToken do
    association :user

    before(:create) do |blacklist_token, evaluator|
      payload = { exp: Time.now.to_i }
      request = { "HTTP_HOST": "localhost:3000", "REQUEST_URI": "/api" }
      access_token, refresh_token = Jwt::Generator.new(user: blacklist_token.user, req: request, payload: payload).call
      blacklist_token.token = access_token
    end
  end
end
