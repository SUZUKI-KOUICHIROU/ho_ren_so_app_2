FactoryBot.define do
  factory :message_confirmer do
    message_confirmer_id { 1 }
    message_confirmation_flag { false }
    message { nil }
  end
end
