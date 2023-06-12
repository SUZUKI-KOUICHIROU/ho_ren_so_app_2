FactoryBot.define do
  factory :radio_button do
    association :question
    id { 1 }
    question_id { 1 } 
    label_name { 'ラベル名' }  
    field_type { 'radio_button' }    
    created_at { Date.current }
    updated_at { Date.current }
  end
end
