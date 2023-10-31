class ReminderJob < ApplicationJob
  queue_as :default

  def perform(member_id, report_time)
      # TODO: メール送信の処理を追加
      # member_idとreport_timeを使ってメールを送信します。
  end
end
