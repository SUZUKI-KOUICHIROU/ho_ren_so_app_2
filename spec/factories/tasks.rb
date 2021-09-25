FactoryBot.define do
  factory :task do
    task_name { 'MyString' }
    task_rep_id { 1 }
    task_report_frequency { 1 }
    task_next_report_date { '2021-09-01' }
    task_reported_flag { false }
    project { nil }
  end
end
