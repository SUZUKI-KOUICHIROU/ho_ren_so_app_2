module Projects::BaseProjectHelper
  def project_leader?
    return current_user == @project.leader_id
  end
end
