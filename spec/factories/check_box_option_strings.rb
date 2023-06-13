FactoryBot.define do
  factory :check_box_option_string do
    association :check_box
    id { 1 }
    check_box_id { 1 }
    option_string { 'test' }
    created_at { Date.current }
    updated_at { Date.current }
  end
end
