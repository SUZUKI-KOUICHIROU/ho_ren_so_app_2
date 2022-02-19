FactoryBot.define do
  factory :message do
    message_detail { 'MyText' }
    project { nil }
  end
end
