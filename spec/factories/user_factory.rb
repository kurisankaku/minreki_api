FactoryGirl.define do
  factory :user do
    id { SecureRandom.hex(64) }
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "1a" + Faker::Internet.password(6) }
    failed_attempts { 0 }
  end
end
