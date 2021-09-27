FactoryBot.define do
  factory :user, class: User do
    email { "foobar@bazboz.com" }
    password { 'testtest' }
    password_confirmation { 'testtest' }
  end
end