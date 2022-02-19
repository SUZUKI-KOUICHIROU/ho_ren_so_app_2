FactoryBot.define do
  factory :report do
    report_detail { 'MyText' }
    problem_detail { 'MyText' }
    project { nil }
  end
end
