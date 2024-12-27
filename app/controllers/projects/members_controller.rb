class Projects::MembersController < Projects::BaseProjectController
  skip_before_action :correct_user, only: %i[join]
  before_action :project_authorization, only: %i[index destroy delegate cancel_delegate send_reminder reset_reminder]
  before_action :admin_user, only: %i[setting set_admin]
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

    # 報告頻度の取得（報告リマインド日にち選択用）
    @report_frequency = @project.report_frequency

    # プロジェクトユーザーの取得（報告リマインド設定表示用）
    @project_user = find_project_user(@project, @user.id)

    # プロジェクトメンバーの検索＆取得
    @members = fetch_members(@project)

    respond_to do |format| # リクエストスペック用のレスポンス指定
      format.html # デフォルトのHTML形式
      format.json { render_members_json } # JSON形式で返す
    end
  end

  # プロジェクトメンバーをプロジェクトの集計から外す
  def destroy
    user = User.find(params[:member_id])
    project = Project.find(params[:project_id])
    project_user = ProjectUser.find_by(project_id: project.id, user_id: user.id)
    if project.leader_id != user.id
      unless project_user.member_expulsion
        project_user.destroy
        flash[:success] = "#{user.name}さんをプロジェクトから外しました。"
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

  # 報告リマインダーの設定を行うアクション
  def send_reminder
    user_id = params[:user_id].to_i
    project_id = params[:project_id].to_i
    member_id = params[:member_id].to_i
    report_frequency = params[:report_frequency].to_i
    reminder_days = params[:reminder_days].to_i
    report_time = params[:report_time]

    # 1. ユーザーとプロジェクトを取得
    user, project = find_user_and_project(user_id, project_id)
    return unless user && project

    # 2. リマインダー用の各処理を実行
    process_report_reminder(project, member_id, report_frequency, reminder_days, report_time)

    # 3. 設定情報を返す
    render json: { success: true }, status: :ok
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  # 報告リマインダーの設定をリセットするアクション
  def reset_reminder
    user_id = params[:user_id].to_i
    project_id = params[:project_id].to_i
    member_id = params[:member_id].to_i

    # 1. ユーザーとプロジェクトを取得
    user, project = find_user_and_project(user_id, project_id)
    return unless user && project

    # 2. リマインダー用の各解除処理を実行
    process_disable_reminder(project, member_id)

    # 3. 設定情報を返す
    render json: { success: true }, status: :ok
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  # 設定ページ表示
  def setting
    @user = User.find(params[:user_id])
    @users = User.all.order(:id)
  end

  # 管理者権限変更
  def set_admin
    @user = User.find(params[:admin_id])
    if @user.update(admin_setting_params)
      render json: { status: 'SUCCESS', message: 'Updated the User', data: @user }
    else
      render json: { status: 'ERROR', message: 'User not updated', data: @user.errors }
    end
  end

  private

  # プロジェクトメンバーを検索＆取得するメソッド（index用）
  def fetch_members(project)
    if params[:search].present?
      ProjectUser.member_expulsion_join(project, project.users.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).per(10))
    else
      ProjectUser.member_expulsion_join(project, project.users.all.page(params[:page]).per(10))
    end
  end

  # JSON 形式でメンバーの一覧をレンダリングするメソッド（index用）
  def render_members_json
    render json: {
      members: @members,
      search_box: true,
      delegates: @delegates,
      report_frequency: @report_frequency,
      project_user: @project_user
    }
  end

  # ユーザーとプロジェクトを取得するメソッド（報告リマインド用）
  def find_user_and_project(user_id, project_id)
    user = User.find_by(id: user_id)
    project = Project.find_by(id: project_id)

    # ユーザーまたはプロジェクトが見つからない場合はエラーレスポンスを返す
    raise StandardError, "ユーザーまたはプロジェクトが見つかりません。" unless user && project

    [user, project]
  end

  # プロジェクトユーザーを取得するメソッド（報告リマインド用）
  def find_project_user(project, member_id)
    project_user = ProjectUser.find_by(project_id: project.id, user_id: member_id)
    return project_user if project_user

    flash[:error] = "プロジェクトメンバーが見つかりません。"
    redirect_to root_path
    nil
  end

  # リマインダー設定用の各処理を実行するメソッド（報告リマインド用）
  def process_report_reminder(project, member_id, report_frequency, reminder_days, report_time)
    Time.use_zone('Asia/Tokyo') do
      project_user = find_project_user(project, member_id)
      return unless project_user

      # 指定日時にリマインドジョブをキューに追加
      project_user.queue_report_reminder(project.id, member_id, report_frequency, reminder_days, report_time)

      # リマインダーの設定情報を保存
      project_user.update!(
        reminder_enabled: true,
        reminder_days: reminder_days,
        report_time: report_time
      )

      # 設定した project_user を返す
      project_user
    end
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, e.message
  end

  # リマインダー設定の解除処理を実行するメソッド（報告リマインド用）
  def process_disable_reminder(project, member_id)
    project_user = find_project_user(project, member_id)
    return unless project_user

    # リマインダージョブをキューから削除
    project_user.dequeue_report_reminder(project.id, member_id)

    # リマインダーの設定情報を解除
    project_user.update!(
      reminder_enabled: false,
      reminder_days: nil,
      report_time: nil,
      report_reminder_time: nil
    )

    # 設定した project_user を返す
    project_user
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError, e.message
  end

  # 管理者権限更新用パラメータ
  def admin_setting_params
    params.require(:user).permit(:admin)
  end
end
