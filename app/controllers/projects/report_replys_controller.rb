class Projects::ReportReplysController < Projects::BaseProjectController
  def index
  end

  def show
  end

  def new
  end

  def edit
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    @index = params[:index]
  end

  def create
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:report_id])
    @reply = @report.report_replies.new(report_reply_params)
    if @reply.save
      flash[:success] = '返信を投稿しました。'
    else
      flash[:danger] = '返信の投稿に失敗しました。'
    end
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def update
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    if @reply.update(report_reply_params)
      flash[:success] = "返信内容を更新しました。"
    else
      flash[:danger] = "返信の更新に失敗しました。"
    end
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def destroy
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    if @reply.destroy
      flash[:success] = "返信を削除しました。"
    else
      flash[:danger] = "返信の削除に失敗しました。"
    end
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def cancel
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    @index = params[:index]
  end

  private

  def report_reply_params
    params.require(:report_reply).permit(:reply_content, :poster_name, :poster_id)
  end
end
