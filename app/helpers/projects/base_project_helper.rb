module Projects::BaseProjectHelper
  def project_leader?
    debugger
    return current_user == @project.project_leader_id
  end
end
