FactoryBot.define do
  factory :counseling do
    counseling_detail { 'MyText' }
    counseling_reply_deadline { '2021-09-01' }
    counseling_reply_detail { 'MyText' }
    counseling_reply_flag { false }
    project { nil }
    task { nil }
  end
end
