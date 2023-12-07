class Projects::CounselingReplysController < Projects::BaseProjectController
  before_action :project_authorization, only: %i[edit create update destroy cancel delete_image]

  def edit
    @counseling = Counseling.find(params[:counseling_id])
    @reply = CounselingReply.find(params[:id])
    @index = params[:index]
  end

  def create
    @counseling = Counseling.find(params[:counseling_id])
    unless params[:counseling_reply][:images].nil?
      set_enable_images(params[:counseling_reply][:image_enable], params[:counseling_reply][:images])
    end
    @reply = @counseling.counseling_replies.new(counseling_reply_params)
    if @reply.save
      flash[:success] = '返信を投稿しました。'
    else
      flash[:danger] = '返信の投稿に失敗しました。'
    end
    redirect_to user_project_counseling_path(@user, @project, @counseling)
  end

  def update
    @counseling = Counseling.find(params[:counseling_id])
    @reply = CounselingReply.find(params[:id])
    if @reply.update(counseling_reply_params)
      flash[:success] = "返信内容を更新しました。"
    else
      flash[:danger] = "返信の更新に失敗しました。"
    end
    redirect_to user_project_counseling_path(@user, @project, @counseling)
  end

  def destroy
    @counseling = Counseling.find(params[:counseling_id])
    @reply = CounselingReply.find(params[:id])
    @reply.images.purge  # 返信に紐づく画像データの削除
    if @reply.destroy
      flash[:success] = "返信を削除しました。"
    else
      flash[:danger] = "返信の削除に失敗しました。"
    end
    redirect_to user_project_counseling_path(@user, @project, @counseling)
  end

  def cancel
    @counseling = Counseling.find(params[:counseling_id])
    @reply = CounselingReply.find(params[:id])
    @index = params[:index]
  end

  def show_image
    @image = ActiveStorage::Attachment.find(params[:image_id])
  end

  def delete_image
    @counseling = Counseling.find(params[:counseling_id])
    @image = ActiveStorage::Attachment.find(params[:image_id])
    @image.purge
    flash[:success] = "画像を削除しました。"
    redirect_to user_project_counseling_path(@user, @project, @counseling)
  end

  private

  def counseling_reply_params
    params.require(:counseling_reply).permit(:reply_content, :poster_name, :poster_id, images: [])
  end
end
