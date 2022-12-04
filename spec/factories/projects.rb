FactoryBot.define do
  factory :project do
    project_name { 'MyString' }
    leader_id { 1 }
    report_frequency { 1 }
    next_report_date { '2021-09-01' }
    project_reported_flag { false }
  end
end
