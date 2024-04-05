FactoryBot.define do
  factory :project_user do
    association :user, factory: :unique_user
    association :project

    member_expulsion { false } # メンバー除外カラムのデフォルト値を指定
    report_reminder_time { nil } # 設定日＆選択時刻カラムのデフォルト値を指定
    reminder_enabled { false } # リマインダー有効無効カラムのデフォルト値を指定
    reminder_days { nil } # 選択日数カラムのデフォルト値を指定
    report_time { nil } # 選択時刻カラムのデフォルト値を指定

    trait :with_reminder do
      report_reminder_time { Time.zone.now }
      reminder_days { 1 }
      report_time { Time.zone.now.strftime('%H:%M:%S') }
    end
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
