FactoryBot.define do
  factory :select_option_string do
    association :select
    id { 1 }
    select_id { 1 }
    option_string { 'test' }
    created_at { Date.current }
    updated_at { Date.current }
  end
end
