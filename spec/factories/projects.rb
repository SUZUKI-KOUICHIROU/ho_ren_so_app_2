FactoryBot.define do
  factory :project do
    name              { 'プロジェクトA' }
    description       { '概要A' }
    leader_id         { 1 }
    report_frequency  { 1 }
    next_report_date  { Date.current }
    reported_flag     { false }
  end

  trait :with_report_deadline do
    after(:build) do |project|
      report_deadline = build(:report_deadline, project: project)
      project.report_deadlines << report_deadline
    end
  end

  trait :project_2 do
    name              { 'プロジェクトB' }
    description       { '概要B' }
    leader_id         { 1 }
    report_frequency  { 3 }
    next_report_date  { Date.current }
    reported_flag     { false }
  end
end
