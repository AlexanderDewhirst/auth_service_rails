FactoryBot.define do
  factory :blacklist_token, class: BlacklistToken do
    association :user

    before(:create) do |blacklist_token, evaluator|
      blacklist_token.token = Jwt::Generator.new(user: blacklist_token.user, payload: { exp: Time.now.to_i }).call
    end
  end
end
