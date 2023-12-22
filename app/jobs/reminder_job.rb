class ReminderJob < ApplicationJob
  queue_as :default

  # 報告リマインドメールを送信する処理
  def perform(project_id, member_id, reminder_days, report_time)
    project_user = ProjectUser.find(member_id)
    project = Project.find(project_id)

    # project_userモデルの calculate_reminder_time メソッドを呼び出す
    reminder_time = project_user.calculate_reminder_time(reminder_days, report_time)

    # 追加: ログ出力
    logger.debug "Performing report reminder job for user #{member_id} in project #{project_id} at #{reminder_time}"

    # 指定時刻まで待機
    wait_until_report_reminder_time(reminder_time)
    
    # 追加: ログ出力
    logger.debug "Performing report reminder job for user #{member_id} in project #{project_id} at #{reminder_time}"

    # 指定の日にち＆時刻になったらメール送信
    send_reminder_email(project_user, project, reminder_days, report_time)
  end

  private

  # 指定時刻まで待機させるメソッド
  def wait_until_report_reminder_time(reminder_time)
    # タイムゾーンをJSTに変換
    jst_reminder_time = reminder_time.in_time_zone('Asia/Tokyo')

    # 追加: ログ出力
    logger.debug "Waiting until report reminder time: #{jst_reminder_time}"

    # 1秒ごとに確認
    loop do
      break if Time.zone.now >= jst_reminder_time

      sleep(1)
    end
  end

  # 指定の日にち＆時刻になったらメールを送信させるメソッド
  def send_reminder_email(project_user, project, reminder_days, report_time)
    # member_idとreport_timeを使い、非同期処理でメールを送信
    UserMailer.reminder_email(project_user.user_id, reminder_days, report_time, project.id).deliver_later
  end
end
