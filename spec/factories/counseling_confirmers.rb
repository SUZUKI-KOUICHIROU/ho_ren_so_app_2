FactoryBot.define do
  factory :counseling_confirmer do
    counseling_confirmer_id { 1 }
    counseling_confirmation_flag { false }
    counseling { nil }
  end
end
