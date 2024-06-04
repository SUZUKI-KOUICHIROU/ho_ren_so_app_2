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
    @project = if params[:project_id].present?
                 Project.find(params[:project_id])
               else
                 Project.find(params[:id])
               end
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

  # 画像添付機能：使用する画像リストの設定 (プレビュー表示時に取り消しした画像をDBに登録しないための処置）
  def set_enable_images(image_enable_info, images_array)
    rmv_num = 0
    img_enable_array = image_enable_info.split(',')

    img_enable_array.each_with_index do |value, idx|
      if value == "false"
        images_array.delete_at(idx - rmv_num)
        rmv_num += 1
      end
    end

    return images_array
  end

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # # プロジェクトリーダーを許可
  def project_leader_user
    @project = if params[:project_id].present?
                 Project.find(params[:project_id])
               else
                 Project.find(params[:id])
               end
    return if current_user.id == @project.leader_id

    flash[:danger] = 'リーダーではない為、権限がありません。'
    redirect_to user_project_path(@user, @project)
  end

  # 管理者ユーザーを許可
  def admin_user
    return if current_user.admin?
    
    flash[:danger] = t('flash.not_admin')
    redirect_to root_path
  end
end
