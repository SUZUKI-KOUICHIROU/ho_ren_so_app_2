FactoryBot.define do
  factory :question do
    association :project
    id { 1 }
    position { 1 }
    form_table_type { 'text_field' }
    project_id { 1 } 
    using_flag { true }
    required { true }     
    created_at { Date.current }
    updated_at { Date.current }
  end
end
