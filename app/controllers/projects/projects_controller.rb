class Projects::ProjectsController < Projects::BaseProjectController
  before_action :authenticate_user!, only: %i[index new create]
  before_action :project_authorization, only: %i[show edit update destroy delegate_leader accept_request disown_request]
  before_action :project_leader_user, only: %i[edit update destroy]

  # プロジェクト一覧ページ表示アクション
  def index
    @user = current_user
    @report_statuses = ReportStatus.where(user_id: @user.id, is_newest: true)
    @projects =
      if params[:search].present?
        @user.projects.where('name LIKE ?', "%#{params[:search]}%").page(params[:page]).per(10)
      else
        @user.projects.all.page(params[:page]).per(10)
      end
  end

  # プロジェクト詳細ページ表示アクション
  def show
    @delegate = @project.delegations.find_by(user_to: @user.id, is_valid: true)
    @counselings = @project.counselings.my_counselings(current_user)
    @messages = @project.messages.my_recent_messages(current_user)
    @member = @project.users.all.where.not(id: @project.leader_id)
    @remanded_reports = @project.reports.where(user_id: @user.id, remanded: true)
  end

  # プロジェクト新規登録用モーダルウインドウ表示アクション
  def new
    @user = current_user
    @project = @user.projects.new
  end

  # プロジェクト編集ページ表示アクション
  def edit
    if @project.report_frequency == 7
      @report_frequency_type = 'week'
      next_report_date_wday = @project.next_report_date.wday
      @next_report_date_week = ApplicationHelper.weeks[next_report_date_wday]
    else
      @report_frequency_type = 'day'
    end
  end

  # プロジェクト新規登録アクション
  def create
    @user = current_user
    if @user.projects.new(project_params).valid?
      @project = @user.projects.create(project_params)
      @project.update_next_report_date(project_params[:report_frequency_selection], project_params[:week_select])
      @project.update_deadline(@project.next_report_date)
      @project.report_deadlines.create!(day: @project.next_report_date)
      @project.report_format_creation # デフォルト報告フォーマット作成アクション呼び出し
      flash[:success] = 'プロジェクトを新規登録しました。'
      redirect_to user_project_path(@user, @project)
      @project.create_format(title: '件名')
    else
      flash[:danger] = 'プロジェクト新規登録に失敗しました。'
      redirect_to user_projects_path(@user)
    end
  end

  # プロジェクト内容編集アクション
  def update
    if @project.update(project_params)
      @project.update_next_report_date(project_params[:report_frequency_selection], project_params[:week_select])
      @project.report_deadlines.last.update(day: @project.next_report_date)
      flash[:success] = "#{@project.name}の内容を更新しました。"
    else
      flash[:danger] = "#{@project.name}の更新は失敗しました。"
    end
    redirect_to user_project_path(@user, @project)
  end

  # プロジェクト削除アクション
  def destroy
    if @project.destroy
      flash[:success] = "#{@project.name}を削除しました。"
    else
      flash[:success] = "#{@project.name}の削除に失敗しました。"
    end
    redirect_to user_projects_path(@user.id)
  end

  def invitations; end

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

  def frequency_input_form_switching
    @user = User.find(params[:user_id])
    case params[:form_type]
    when 'day', 'week'
      @project = @user.projects.new(name: params[:name], description: params[:project_description])
    when 'edit_day', 'edit_week'
      @project = @user.projects.find(params[:project_id])
      @project.name = params[:name]
      if @project.report_frequency == 7
        next_report_date_wday = @project.next_report_date.wday
        @next_report_date_week = ApplicationHelper.weeks[next_report_date_wday]
      end
    end
  end

  # リーダー権限委譲リクエスト受認クリック時アクション
  def accept_request
    @delegate = @project.delegations.find(params[:delegate_id])
    @project.update(leader_id: params[:user_id])
    @delegate.update(is_valid: false)
    flash[:success] = "あなたがリーダーになりました。"
    redirect_to user_project_path(@user, @project)
  end

  # リーダー権限委譲リクエスト辞退クリック時アクション
  def disown_request
    @delegate = @project.delegations.find(params[:delegate_id])
    @delegate.update(is_valid: false)
    flash[:success] = "リーダー交代リクエストを辞退しました。"
    redirect_to user_project_path(@user, @project)
  end

  private

  def project_params
    params.require(:project).permit(
      :name, :leader_id,
      :report_frequency,
      :next_report_date,
      :description,
      :report_frequency_selection,
      :week_select
    )
  end
end
