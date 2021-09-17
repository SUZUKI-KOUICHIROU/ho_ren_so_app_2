class Users::ProjectsController < Users::UserBaseController
  before_action :project_reader_user, only: %i[edit update destroy]

  # プロジェクト一覧ページ表示アクション
  def index
    @user = User.find(params[:user_id])
    @projects =
      if params[:search].present?
        @user.Project.where('project_name LIKE ?', "%#{params[:search]}%")
      else
        @user.projects.all
      end
  end

  # プロジェクト新規登録アクション
  def create
    @user = User.find(params[:user_id])
    project_name = project_params[:project_name]
    project_leader_id = project_params[:project_leader_id]
    project_report_frequency = project_params[:project_report_frequency]
    project_next_report_date = Date.current.since(project_params[:project_report_frequency].to_i.days)
    @project = @user.projects.create(project_name: project_name,
                                     project_leader_id: project_leader_id,
                                     project_report_frequency: project_report_frequency,
                                     project_next_report_date: project_next_report_date)
    flash[:success] = 'プロジェクトを新規登録しました。'
    redirect_to users_user_projects_path(@user.id)
  end

  # プロジェクト新規登録用モーダルウインドウ表示アクション
  def new
    @user = User.find(params[:user_id])
    @project = @user.projects.new
  end

  # プロジェクト編集用モーダルウインドウ表示アクション
  def edit
    @project = Project.find(params[:id])
  end

  # プロジェクト詳細確認用モーダルウインドウ表示アクション
  def show
    @project = Project.find(params[:id])
  end

  # プロジェクト内容編集アクション
  def update
    @project = Project.find(params[:id])
    @project.update(project_params)
    @projects = Project.all
  end

  # プロジェクト削除アクション
  def destroy
    @user = User.find(params[:user_id])
    @project = Project.find(params[:id])
    @product.destroy
    flash[:success] = "#{@project.project_name}を削除しました。"
    redirect_to users_user_projects_path(@user.id)
  end

  private

  def project_params
    params.require(:project).permit(:project_name, :project_leader_id, :project_report_frequency)
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
