module Projects::ProjectsHelper
  def project_leader?
    return current_user.id == @project.project_leader_id
  end
end
