FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }

    trait :admin do
      role { :admin }
    end

    trait :regular do
      role { :regular }
    end
  end
end