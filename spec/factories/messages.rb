FactoryBot.define do
  factory :message do
    association :project
    id { 1 }
    project_id { 1 }
    sender_id { 1 }
    sender_name { '連絡者' }
    title { 'a' * 25 }
    message_detail { '連絡内容' }
    importance { '中' }
    created_at { '2023-01-01' }
    updated_at { '2023-01-01' }
  end
end
