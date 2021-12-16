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
    redirect_to user_project_path current_user,params[:project_id]
  end

  def index
    @user = current_user
    @project = Project.find(params[:project_id])
    @member = @project.users.all
    @counselings = @project.counselings.my_counselings(current_user)
  end

  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @member = @project.users.all
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
