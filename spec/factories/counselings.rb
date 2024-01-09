FactoryBot.define do
  factory :counseling do
    association :project
    id { 1 }
    project_id { 1 }
    sender_id { 1 }
    sender_name { '相談者' }
    title { 'a' * 25 }
    counseling_detail { '相談内容' }
    created_at { '2023-01-01' }
    updated_at { '2023-01-01' }
  end
end
