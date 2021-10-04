FactoryBot.define do
  factory :message do
    message_detail { 'MyText' }
    project { nil }
    task { nil }
  end
end
