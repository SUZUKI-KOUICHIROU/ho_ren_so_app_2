FactoryBot.define do
  factory :text_area do
    association :question
    id { 1 }
    question_id { 1 } 
    label_name { 'ラベル名' }  
    field_type { 'text_area' }    
    created_at { Date.current }
    updated_at { Date.current }
  end
end
