class Projects::ReportReplysController < Projects::BaseProjectController
  before_action :project_authorization, only: %i[edit create update destroy cancel delete_image]

  def edit
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    @index = params[:index]
  end

  def create
    @report = Report.find(params[:report_id])
    unless params[:report_reply][:images].nil?
      set_enable_images(params[:report_reply][:image_enable], params[:report_reply][:images])
    end
    @reply = @report.report_replies.new(report_reply_params)
    if @reply.save
      flash[:success] = '返信を投稿しました。'
    else
      flash[:danger] = '返信の投稿に失敗しました。'
    end
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def update
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
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    @reply.images.purge  # 返信に紐づく画像データの削除
    if @reply.destroy
      flash[:success] = "返信を削除しました。"
    else
      flash[:danger] = "返信の削除に失敗しました。"
    end
    redirect_to user_project_report_path(@user, @project, @report)
  end

  def cancel
    @report = Report.find(params[:report_id])
    @reply = ReportReply.find(params[:id])
    @index = params[:index]
  end

  def show_image
    @image = ActiveStorage::Attachment.find(params[:image_id])
  end

  def delete_image
    @report = Report.find(params[:report_id])
    @image = ActiveStorage::Attachment.find(params[:image_id])
    @image.purge
    flash[:success] = "画像を削除しました。"
    redirect_to user_project_report_path(@user, @project, @report)
  end

  private

  def report_reply_params
    params.require(:report_reply).permit(:reply_content, :poster_name, :poster_id, images: [])
  end
end
