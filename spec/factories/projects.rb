FactoryBot.define do
  factory :project do
    name { 'MyString' }
    leader_id { 1 }
    report_frequency { 1 }
    next_report_date { '2021-09-01' }
    reported_flag { false }
  end
end
