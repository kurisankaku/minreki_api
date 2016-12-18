FactoryGirl.define do
  factory :user do
    id { SecureRandom.hex(64) }
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "1a" + Faker::Internet.password(6) }
    password_confirmation { password }
    failed_attempts { 0 }

    transient do
      skip_confirm true
    end

    after(:build) do |user, evaluator|
      user.skip_confirmation! if evaluator.skip_confirm
    end
  end
end
