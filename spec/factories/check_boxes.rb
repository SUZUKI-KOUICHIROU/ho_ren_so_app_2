FactoryBot.define do
  factory :check_box do
    association :question
    id { 1 }
    question_id { 1 }
    label_name { 'ラベル名' }
    field_type { 'check_box' }
    created_at { Date.current }
    updated_at { Date.current }
  end
end
