class Projects::ProjectsController < Projects::BaseProjectController
  before_action :project_reader_user, only: %i[edit update destroy]

  # プロジェクト一覧ページ表示アクション
  def index
    @user = current_user
    @project = Project.first
    @counselings = @project.counselings.my_counselings(current_user)
    # @messages = @project.messages.my_recent_messages(current_user)
    @member = @project.users.all
    # @remanded_reports = @project.reports.where(user_id: @user.id, remanded: true)
    @projects =
      if params[:search].present?
        @user.projects.where('project_name LIKE ?', "%#{params[:search]}%").page(params[:page]).per(5)
      else
        @user.projects.all.page(params[:page]).per(5)
      end
  end

  # プロジェクト新規登録アクション
  def create
    @user = User.find(params[:user_id])
    if @user.projects.new(project_params).valid?
      @project = @user.projects.create(project_params)
      flash[:success] = 'プロジェクトを新規登録しました。'
    else
      'プロジェクト新規登録に失敗しました。'
    end
    @project.update_deadline(@project.project_next_report_date)
    redirect_to user_projects_path(@user.id)
    report_format_creation(@project) # デフォルト報告フォーマット作成アクション呼び出し
  end

  # プロジェクト新規登録用モーダルウインドウ表示アクション
  def new
    @user = User.find(params[:user_id])
    @project = @user.projects.new
  end

  # プロジェクト編集用モーダルウインドウ表示アクション
  def edit
    @user = User.find(params[:user_id])
    @project = Project.find(params[:id])
    if @project.project_report_frequency == 7
      @report_frequency_type = 'week'
      project_next_report_date_wday = @project.project_next_report_date.wday
      @project_next_report_date_week = ApplicationHelper.weeks[project_next_report_date_wday]
    else
      @report_frequency_type = 'day'
    end
  end

  # プロジェクト詳細ページ表示アクション
  def show
    @user = current_user
    @project = Project.find(params[:id])
    # @messages = @project.my_messages(current_user)
    @counselings = @project.counselings.my_counselings(current_user)
    @messages = @project.messages.my_recent_messages(current_user)
    @member = @project.users.all
    @remanded_reports = @project.reports.where(user_id: @user.id, remanded: true)
  end

  # プロジェクト内容編集アクション
  def update
    user = User.find(params[:user_id])
    @project = Project.find(params[:id])
    @projects = Project.all
    if @project.update(project_params)
      flash[:success] = "#{@project.project_name}の内容を更新しました。"
    else
      flash[:danger] = "#{@project.project_name}の更新は失敗しました。"
    end
    redirect_to user_projects_path(user)
  end

  # プロジェクト削除アクション
  def destroy
    @user = User.find(params[:user_id])
    @project = Project.find(params[:id])
    @project.destroy
    flash[:success] = "#{@project.project_name}を削除しました。"
    redirect_to user_projects_path(@user.id)
  end

  def invitations; end

  def join
    user = User.find_by(email: params[:email])
    @join = Join.find_by(token: params[:token])
    @user = User.find(@join.user_id)
    @project = Project.find_by(id: @join.project_id)
    @project.users << @user
    if @user.sign_in_count == 0
      bypass_sign_in user
      redirect_to edit_user_registration_path(@user)
    else
      bypass_sign_in user
      redirect_to new_page_after_login_path(@user)
    end
  end

  def frequency_input_form_switching
    @user = User.find(params[:user_id])
    case params[:form_type]
    when 'day', 'week'
      @project = @user.projects.new(project_name: params[:project_name])
    when 'edit_day', 'edit_week'
      @project = @user.projects.find(params[:project_id])
      @project.project_name = params[:project_name]
      if @project.project_report_frequency == 7
        project_next_report_date_wday = @project.project_next_report_date.wday
        @project_next_report_date_week = ApplicationHelper.weeks[project_next_report_date_wday]
      end
    end
  end


  private

  def project_params
    params.require(:project).permit(:project_name, :project_leader_id, :project_report_frequency, :project_next_report_date, :description)
  end

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # プロジェクトリーダーを許可
  def project_reader_user
    @project = Project.find(params[:id])
    return if current_user.id == @project.project_leader_id

    flash[:danger] = 'リーダーではない為、権限がありません。'
    redirect_to users_user_projects_path(params[:id])
  end
end
