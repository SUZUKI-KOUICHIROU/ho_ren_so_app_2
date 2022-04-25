# 報告がまだのメンバーにリマインドメールを送る処理
class Batch::SendRemind
  def self.send_remind
    targetDate = Date.yesterday #報告は期日の翌朝のため、前日付期日が処理対象
    Project.all.each do |project|
      if project.project_next_report_date == targetDate
        members = project.report_statuses.where(has_reminded: false, has_submitted: false, deadline: targetDate).pluck(:user_id)
        users = project.users.where(id: members)
        users.each do |user|
          UserMailer.send_remind(project.project_name, user.email).deliver
        end
      end
    end
    puts 'sended remind mail!'
  end
end
