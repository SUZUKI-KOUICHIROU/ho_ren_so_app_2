FactoryBot.define do
  factory :report_deadline do
    day { Date.current }
    project
  end
end
