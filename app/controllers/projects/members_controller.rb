class Projects::MembersController < Projects::BaseProjectController
  skip_before_action :correct_user, only: %i[join]
  # before_action :project_leader_user, only: %i[index]

  # プロジェクトへの参加アクション（招待メールに張付リンククリック時アクション）
  def join
    @join = Join.find_by(token: params[:token])
    @user = User.find(@join.user_id)
    @project = Project.find_by(id: @join.project_id)
    unless @project.users.exists?(id: @user)
      @project.users << @user
      @project.join_new_member(@user.id)
      flash[:success] = "#{@project.name}に参加しました。"
    else
      flash[:success] = '参加済みプロジェクトです。'
    end
    bypass_sign_in @user
    redirect_to user_project_path(@user, @project)
  end

  # プロジェクトに参加しているメンバー一覧ページ表示アクション
  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @delegates = @project.delegations
    @members =
      if params[:search].present?
        ProjectUser.member_expulsion_join(@project, @project.users.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).per(10))
      else
        ProjectUser.member_expulsion_join(@project, @project.users.all.page(params[:page]).per(10))
      end
  end

  # プロジェクトメンバーをプロジェクトの集計から外す
  def destroy
    user = User.find(params[:member_id])
    project = Project.find(params[:project_id])
    project_user = ProjectUser.find_by(project_id: project.id, user_id: user.id)
    if project.leader_id != user.id
      if project_user.member_expulsion
        project_user.update(member_expulsion: false)
        flash[:success] = "#{user.name}さんを報告集計に戻しました。"
      else
        project_user.update(member_expulsion: true)
        flash[:success] = "#{user.name}さんを報告集計から外しました。"
      end
    else
      flash[:success] = "リーダーはメンバーから外せません"
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
