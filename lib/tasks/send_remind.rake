# 名前空間
namespace :send_remind do
  # タスクの説明
  desc "報告がまだのメンバーにリマインドメールを送る処理"
  # タスクの名前
  task :send_remind => :environment do
    targetDate = Date.yesterday # 報告は期日の翌朝のため、前日付期日が処理対象
    Project.all.each do |project|
      if project.next_report_date == targetDate
        members = project.report_statuses.where(has_reminded: false, has_submitted: false, deadline: targetDate).pluck(:user_id)
        users = project.users.where(id: members)
        users.each do |user|
          UserMailer.send_remind(project.name, user.email).deliver
        end
      end
    end
    puts 'sended remind mail!'
  end
end
