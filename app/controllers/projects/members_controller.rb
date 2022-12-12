class Projects::MembersController < Projects::BaseProjectController
  # before_action :project_leader_user, only: %i[index]

  # プロジェクトに参加しているメンバー一覧ページ表示アクション
  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @delegates = @project.delegations
    @members =
      if params[:search].present?
        @project.users.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).per(10)
      else
        @project.users.all.page(params[:page]).per(10)
      end
  end

  def destroy
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    project_user = ProjectUser.find_by(project_id: project.id, user_id: user.id)
    if project_user.destroy
      flash[:success] = "#{user.name}さんをプロジェクトから外しました。"
    else
      flash[:success] = "#{user.name}さんをプロジェクトから外せませんでした。"
    end
    redirect_to project_member_index_path(current_user.id, project.id)
  end

  # リーダー権限委譲リクエストクリック時アクション
  def delegate
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    next_leader = User.find(params[:to])
    project.delegate_leader(user.id, next_leader.id)
    flash[:success] = "#{next_leader.name}さんに権限譲渡のリクエストを送信しました。"
    redirect_to project_member_index_path(current_user.id, project.id)
  end

  # リーダー権限委譲リクエストキャンセルクリック時アクション
  def cancel_delegate
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    delegation = Delegation.find(params[:delegate_id])
    delegation.update(is_valid: false)
    flash[:success] = "リクエストをキャンセルしました。"
    redirect_to project_member_index_path(current_user.id, project.id)
  end
end
