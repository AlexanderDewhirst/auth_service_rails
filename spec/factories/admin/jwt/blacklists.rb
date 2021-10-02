FactoryBot.define do
  factory :blacklist_token, class: BlacklistToken do
    association :user

    before(:create) do |blacklist_token, evaluator|
      token, _ = Jwt::Generator.new(user: blacklist_token.user, payload: { exp: Time.now.to_i }).call
      blacklist_token.token = token
    end
  end
end
