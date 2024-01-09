FactoryBot.define do
  factory :message_reply do
    association :message
    reply_content { '返信内容' }
  end
end
