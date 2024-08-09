class ReminderJob < ApplicationJob
  queue_as :default

  # ジョブ引数のインデックス定義
  ARG_PROJECT_ID_INDEX    = 0
  ARG_MEMBER_ID_INDEX     = 1
  ARG_REMINDER_DAYS_INDEX = 2
  ARG_REPORT_TIME_INDEX   = 3

  # 報告リマインドメールを送信する処理
  def perform(project_id, member_id, reminder_days, report_time)
    project_user = ProjectUser.find(member_id)
    project = Project.find(project_id)

    # projectsテーブルから次回報告日を取得
    next_report_date = project.next_report_date

    # project_userモデルから指定日時の計算＆設定メソッドを呼び出し
    reminder_datetime = project_user.calculate_reminder_datetime(reminder_days, report_time, next_report_date)

    # 指定日時まで待機
    wait_until_report_reminder_datetime(reminder_datetime)

    # 指定日時になったらメールを送信
    send_reminder_email(project_user, project, reminder_days, report_time)
  end

  private

  # 指定日時まで待機させるメソッド
  def wait_until_report_reminder_datetime(reminder_datetime)
    # タイムゾーンを日本時刻JSTに変換
    jst_reminder_datetime = reminder_datetime.in_time_zone('Asia/Tokyo')

    # 1秒ごとに確認
    loop do
      break if Time.zone.now >= jst_reminder_datetime

      sleep(1)
    end
  end

  # 指定日時になったらメールを送信させるメソッド
  def send_reminder_email(project_user, project, reminder_days, report_time)
    # member_idとreport_timeを使い、非同期処理でメールを送信
    UserMailer.reminder_email(project_user.user_id, project.id, reminder_days, report_time).deliver_later
  end
end
