class Formats::BaseFormatController < BaseController
  before_action :project_leader_user

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # プロジェクトリーダーを許可
  def project_leader_user
    @project = Project.find(params[:project_id])
    return if current_user.id == @project.project_leader_id

    flash[:danger] = 'リーダーではない為、権限がありません。'
    redirect_to user_project_path(current_user, @project)
  end
end
