FactoryBot.define do
  factory :user do
    id { 1 }
    name { 'ユーザー1' }
    email { 'sample-1@email.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    has_editted { true }

    trait :user_with_projects do
      after(:build) do |user|
        user.projects << build(:project, :with_report_deadline)
      end
    end

    trait :user_2 do
      id { 2 }
      name { 'ユーザー2' }
      email { 'sample-2@email.com' }
      password { 'password' }
      password_confirmation { 'password' }
      admin { false }
      has_editted { true }
    end
  end
end
