# 報告期日を更新する処理（未完成&動作させるコードはコメントアウト中）
Project.all.each do |project|
  targetDate = Date.yesterday
  if project.project_next_report_date == targetDate
    project.report_statuses.where(is_newest: true).update_all(is_newest: false)
    project.users.all.each do |user|
      unless project.report_statuses.exists?(user_id: user.id, deadline: project.project_next_report_date)
        report_status = project.report_statuses.new(user_id: user.id, deadline: project.project_next_report_date)
        report_status.save
      end
    end
  end
end