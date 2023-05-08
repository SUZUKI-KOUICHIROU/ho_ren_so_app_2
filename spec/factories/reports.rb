FactoryBot.define do
  factory :report do
    association :project
    id { 1 }
    project_id { 1 }
    sender_id { 1 }    
    sender_name { 'MyText' }
    title { 'タイトル' }
    report_day { Date.current }
    created_at { Date.current }
    updated_at { Date.current }
  end
end
