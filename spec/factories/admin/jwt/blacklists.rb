FactoryBot.define do
  factory :jwt_blacklist, class: Blacklist do
    association :user

    before(:create) do |jwt_blacklist, evaluator|
      jwt_blacklist.token = Jwt::Generator.new(user: jwt_blacklist.user, payload: { exp: Time.now.to_i }).call
    end
  end
end
