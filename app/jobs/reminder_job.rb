class ReminderJob < ApplicationJob
  queue_as :default

  def perform(member_id, report_time)
    # member_idとreport_timeを使ってメールを送信する処理
    UserMailer.reminder_email(member_id, report_time).deliver_now
  end
end
