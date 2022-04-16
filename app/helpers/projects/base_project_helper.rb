module Projects::BaseProjectHelper
  def project_leader?
    return current_user == @project.project_leader_id
  end
end
