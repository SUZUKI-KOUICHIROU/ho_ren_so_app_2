module Projects::ProjectsHelper
  def project_leader?
    return current_user.id == @project.leader_id
  end
  def report_users(project, report_deadline)
    report_users_id = []
    i = 0
    report_users = project.reports.where(report_day: report_deadline.day).where(remanded: false).select(:user_id).distinct
    report_users.each do |user|
      report_users_id[i] = user.user_id
      i += 1
    end
    return project.users.all.where(id: report_users_id)
  end
end
