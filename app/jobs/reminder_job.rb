class ReminderJob < ApplicationJob
  queue_as :default

  # 報告リマインドメールを送信する処理
  def perform(project_id, member_id, report_time)
    project_user = ProjectUser.find(member_id)
    project = Project.find(project_id)

    # member_idとreport_timeを使ってメールを送信
    UserMailer.reminder_email(project_user.user_id, report_time, project.id).deliver_now
  end
end
