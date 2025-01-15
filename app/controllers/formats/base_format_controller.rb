class Formats::BaseFormatController < BaseController
  before_action :authenticate_user!
  before_action :project_leader_user

  private

  # メンバー外ユーザーをフィルタ
  def project_authorization
    @user = current_user
    @project = Project.find(params[:project_id])
    unless @project.project_users.exists?(user_id: @user)
      redirect_to user_projects_path(@user)
    end
  end
end
