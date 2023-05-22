FactoryBot.define do
  factory :date_field do
    association :question
    id { 1 }
    label_name{ 'ラベル名' }  
    field_type { 'date_field' }
    question_id { 1 }    
    created_at { Date.current }
    updated_at { Date.current }
  end
end
