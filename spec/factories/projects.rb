FactoryBot.define do
  factory :project do
    project_name { "MyString" }
    project_leader_id { 1 }
    project_report_frequency { 1 }
    project_next_report_date { "2021-09-01" }
    project_reported_lag { false }
  end
end
