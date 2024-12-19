FactoryBot.define do
    factory :message do
      content { 'Sample message' }
      association :user
      association :ticket
    end
  end