FactoryBot.define do
  factory :project_user do
    association :user, factory: :unique_user
    association :project

    member_expulsion { false } # メンバー除外カラムのデフォルト値を指定
    report_reminder_time { nil } # 設定日＆選択時刻カラムのデフォルト値を指定
    reminder_enabled { false } # リマインダー有効無効カラムのデフォルト値を指定
    reminder_days { nil } # 選択日数カラムのデフォルト値を指定
    report_time { nil } # 選択時刻カラムのデフォルト値を指定

    trait :with_reminder do # テストジョブ用のサンプルパターン
      report_reminder_time { Time.zone.now }
      reminder_enabled { true }
      reminder_days { 1 }
      report_time { Time.zone.now.strftime('%H:%M:%S') }

      # 未実装のdequeue_report_reminderメソッドをテスト保留させる処理（実装後は要・修正or削除）
      after(:build) do |project_user|
        allow(project_user).to receive(:dequeue_report_reminder).and_return(nil)
      end
    end

    trait :member_expulsion_true do # メンバー除外カラムをtrueにするサンプルパターン
      member_expulsion { true }
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
