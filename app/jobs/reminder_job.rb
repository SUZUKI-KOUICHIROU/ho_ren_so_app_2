class ReminderJob < ApplicationJob
  queue_as :default

  # 報告リマインドメールを送信する処理
  def perform(project_id, member_id, report_frequency, reminder_days, report_time)
    project_user = ProjectUser.find(member_id)
    project = Project.find(project_id)

    # projectsテーブルから次回報告日（next_report_date）を取得
    next_report_date = project.next_report_date

    # project_userモデルの calculate_reminder_datetime メソッドを呼び出す
    reminder_datetime = project_user.calculate_reminder_datetime(report_frequency, reminder_days, report_time, next_report_date)

    # 指定時刻まで待機
    wait_until_report_reminder_datetime(reminder_datetime)
    
    # 指定の日にち＆時刻になったらメール送信
    send_reminder_email(project_user, project, reminder_days, report_time, reminder_datetime)
  end

  private

  # 指定日時まで待機させるメソッド
  def wait_until_report_reminder_datetime(reminder_datetime)
    # タイムゾーンをJSTに変換
    jst_reminder_datetime = reminder_datetime.in_time_zone('Asia/Tokyo')

    # 1秒ごとに確認
    loop do
      break if Time.zone.now >= jst_reminder_datetime

      sleep(1)
    end
  end

  # 指定の日にち＆時刻になったらメールを送信させるメソッド
  def send_reminder_email(project_user, project, reminder_days, report_time, reminder_datetime)
    # member_idとreport_timeを使い、非同期処理でメールを送信
    UserMailer.reminder_email(project_user.user_id, report_time, project.id).deliver_later
  end
end
