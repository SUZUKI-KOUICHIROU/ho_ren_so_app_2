FactoryBot.define do
  factory :report_confirmer do
    report_confirmer_id { 1 }
    report_confirmation_flag { false }
    report { nil }
  end
end
