FactoryBot.define do
  factory :report_confirmer do
    association :report
    id { 1 }
    report_id { 1 }
    report_confirmer_id { 1 }
    report_confirmation_flag { false }
  end
end
