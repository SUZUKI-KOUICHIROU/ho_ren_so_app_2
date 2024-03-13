class Projects::MembersController < Projects::BaseProjectController
  skip_before_action :correct_user, only: %i[join]
  before_action :project_authorization, only: %i[index destroy delegate cancel_delegate send_reminder reset_reminder]
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
  rescue ActiveRecord::RecordNotFound => e
    render json: { success: false, error: e.message }, status: :not_found
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
  rescue ActiveRecord::RecordNotFound => e
    render json: { success: false, error: e.message }, status: :not_found
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  private

  # ユーザーとプロジェクトを取得するメソッド（報告リマインド用）
  def find_user_and_project(user_id, project_id)
    user = User.find_by(id: user_id)
    project = Project.find_by(id: project_id)
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
  end

  # リマインダー設定の解除処理を実行するメソッド（報告リマインド用）
  def process_disable_reminder(project, member_id)
    project_user = find_project_user(project, member_id)
    return unless project_user

    # リマインダージョブをキューから削除
    project_user.dequeue_report_reminder # ※挙動にはSidekiq＋Redisの導入＆引数記述が必要※

    # リマインダーの設定情報を解除
    project_user.update!(
      reminder_enabled: false,
      reminder_days: nil,
      report_time: nil,
      report_reminder_time: nil
    )

    # 設定した project_user を返す
    project_user
  end
end
