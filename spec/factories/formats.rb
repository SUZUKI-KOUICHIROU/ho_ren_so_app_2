FactoryBot.define do
  factory :format do
    association :project
    id { 1 }
    project_id { 1 }  
    title { 'タイトル' }    
    created_at { Date.current }
    updated_at { Date.current }
  end
end
