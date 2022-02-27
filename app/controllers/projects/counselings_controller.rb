class Projects::CounselingsController < BaseController
  def create
    @project = Project.find(params[:project_id])
    @counseling = @project.counselings.new(counseling_params)
    @counseling.sender_id = current_user.id
    @counseling.save
    @counseling.send_to.each do |t|
      @send = @counseling.counseling_confirmers.new(counseling_confirmer_id: t)
      @send.save
    end
    redirect_to user_project_path current_user, params[:project_id]
  end

  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    @counselings = @project.counselings.all.order(update_at: 'DESC').page(params[:page]).per(5)
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    @you_addressee_counselings = @project.counselings.where(id: you_addressee_counseling_ids).order(update_at: 'DESC').page(params[:page]).per(5)
  end

  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @member = @project.users.where.not(id: current_user.id)
    @counseling = @project.counselings.new
  end

  def show
    @user = current_user
    @project = Project.find(params[:project_id])
    # @member = @project.users.all
    @counseling = Counseling.find(params[:id])
    @checkers = @counseling.checkers
    @counseling_c = @counseling.counseling_confirmers.find_by(counseling_confirmer_id: current_user)
  end

  # "確認しました"フラグの切り替え。機能を確認してもらい、実装確定後リファクタリング
  def read
    @project = Project.find(params[:project_id])
    @counseling = Counseling.find(params[:id])
    @counseling_c = @counseling.counseling_confirmers.find_by(Counseling_confirmer_id: current_user)
    @counseling_c.switch_read_flag
    @checkers = @counseling.checkers
  end

  private

  def counseling_params
    params.require(:counseling).permit(:counseling_detail, :title, { send_to: [] })
  end
end
