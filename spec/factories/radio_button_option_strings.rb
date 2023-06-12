FactoryBot.define do
  factory :radio_button_option_string do
    association :radio_button
    id { 1 }
    radio_button_id { 1 } 
    option_string { 'test' }      
    created_at { Date.current }
    updated_at { Date.current }
  end
end
