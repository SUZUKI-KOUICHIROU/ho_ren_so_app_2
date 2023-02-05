module Projects::ProjectsHelper
  def project_leader?
    return current_user.id == @project.leader_id
  end

  def reported_users(project, report_deadline)
    reported_users_id = []
    i = 0
    reported_users = project.reports.where(report_day: report_deadline.day).where(remanded: false)
                            .select(:user_id).distinct
    reported_users.each do |user|
      reported_users_id[i] = user.user_id
      i += 1
    end
    return project.users.all.where(id: reported_users_id)
  end
end
