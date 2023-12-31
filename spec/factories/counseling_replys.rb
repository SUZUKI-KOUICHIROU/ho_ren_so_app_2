FactoryBot.define do
  factory :counseling_reply do
    association :counseling
    reply_content { '返信内容' }
  end
end
