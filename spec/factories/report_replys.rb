FactoryBot.define do
  factory :report_reply do
    association :report
    reply_content { '返信内容' }
  end
end
