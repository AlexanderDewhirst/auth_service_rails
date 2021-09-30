FactoryBot.define do
  factory :blocked_jwt, class: BlockedJwt do
    association :user

    before(:create) do |blocked_jwt, evaluator|
      blocked_jwt.token = GenerateJwt.new(user: blocked_jwt.user, exp: Time.now.to_i).call
    end
  end
end
