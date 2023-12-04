class Projects::MessageReplysController < Projects::BaseProjectController
  before_action :project_authorization, only: %i[edit create update destroy cancel delete_image]

  def edit
    @message = Message.find(params[:message_id])
    @reply = MessageReply.find(params[:id])
    @index = params[:index]
  end

  def create
    @@message = Message.find(params[:message_id])
    unless params[:message_reply][:images].nil?
      set_enable_images(params[:message_reply][:image_enable], params[:message_reply][:images])
    end
    @reply = @@message.message_replies.new(message_reply_params)
    if @reply.save
      flash[:success] = '返信を投稿しました。'
    else
      flash[:danger] = '返信の投稿に失敗しました。'
    end
    redirect_to user_project_message_path(@user, @project, @@message)
  end

  def update
    @@message = Message.find(params[:message_id])
    @reply = MessageReply.find(params[:id])
    if @reply.update(message_reply_params)
      flash[:success] = "返信内容を更新しました。"
    else
      flash[:danger] = "返信の更新に失敗しました。"
    end
    redirect_to user_project_message_path(@user, @project, @@message)
  end

  def destroy
    @message = Message.find(params[:message_id])
    @reply = MessageReply.find(params[:id])
    @reply.images.purge  # 返信に紐づく画像データの削除
    if @reply.destroy
      flash[:success] = "返信を削除しました。"
    else
      flash[:danger] = "返信の削除に失敗しました。"
    end
    redirect_to user_project_message_path(@user, @project, @message)
  end

  def cancel
    @message = Message.find(params[:message_id])
    @reply = MessageReply.find(params[:id])
    @index = params[:index]
  end

  def show_image
    @image = ActiveStorage::Attachment.find(params[:image_id])
  end

  def delete_image
    @message = Message.find(params[:message_id])
    @image = ActiveStorage::Attachment.find(params[:image_id])
    @image.purge
    flash[:success] = "画像を削除しました。"
    redirect_to user_project_message_path(@user, @project, @message)
  end

  private

  def message_reply_params
    params.require(:message_reply).permit(:reply_content, :poster_name, :poster_id, images: [])
  end

  def set_enable_images(image_enable_info, images_array)
    rmv_num = 0
    img_enable_array = image_enable_info.split(',')

    img_enable_array.each_with_index do |value, idx|
      if value == "false"
        images_array.delete_at(idx - rmv_num)
        rmv_num += 1
      end
    end

    return images_array
  end
end
