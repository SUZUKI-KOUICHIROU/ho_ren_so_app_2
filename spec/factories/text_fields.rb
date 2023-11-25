FactoryBot.define do
  factory :text_field do
    association :question
    id { 1 }
    question_id { 1 }
    label_name { 'ラベル名' }
    field_type { 'text_field' }
    created_at { Date.current }
    updated_at { Date.current }
  end
end
