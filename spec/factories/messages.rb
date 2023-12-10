FactoryBot.define do
  factory :message do
    association :project
    id { 1 }
    project_id { 1 }
    sender_id { 1 }
    sender_name { '連絡者' }
    title { 'a' * 25 }
    message_detail { '連絡内容' }
    created_at { Date.current }
    updated_at { Date.current }
  end
end
