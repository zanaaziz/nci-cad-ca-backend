FactoryBot.define do
  factory :ticket do
    name { 'Sample Ticket' }
    description { 'A sample ticket description.' }
    sentiment { 5 }
    association :user
  end
end