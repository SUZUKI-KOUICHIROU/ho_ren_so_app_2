class Projects::BaseProjectController < Users::BaseUserController
  before_action :temporarily_user?

  # ユーザー、プロジェクト、送信先を取得
  def set_project_and_members
    @user = current_user
    @project = Project.find(params[:project_id])
    @members = @project.other_members(@user.id) # 自分以外のメンバーを取得
  end

  # メンバー外ユーザーをフィルタ
  def project_authorization
    @user = current_user
    @project = Project.find(params[:id])
    unless @project.project_users.exists?(user_id: @user) || @user.admin
      flash[:danger] = t('flash.no_access_rights')
      redirect_to user_projects_path(@user)
    end
  end

  # 仮登録のままのユーザーを編集画面へ飛ばす
  def temporarily_user?
    return if current_user.nil?
    return if current_user.has_editted

    flash[:success] = 'ユーザー名を入力してください。'
    redirect_to edit_user_registration_path(current_user)
  end

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # # プロジェクトリーダーを許可
  def project_leader_user
    return if current_user.id == @project.leader_id

    flash[:danger] = 'リーダーではない為、権限がありません。'
    redirect_to user_project_path(@user, @project)
  end
end
