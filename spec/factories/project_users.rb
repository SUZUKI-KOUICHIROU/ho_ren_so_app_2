FactoryBot.define do
  factory :project_user do
    association :user, factory: :unique_user
    association :project

    member_expulsion { false } # member_expulsion のデフォルト値を指定
    report_reminder_time { nil } # report_reminder_time のデフォルト値を指定
  end
end

FactoryBot.define do
  factory :unique_user, class: 'User' do
    name { Faker::Name.name } # ランダムな名前を生成
    email { Faker::Internet.unique.email } # ランダムなメールアドレスを生成
    password { 'password' }
    password_confirmation { 'password' }
  end
end
