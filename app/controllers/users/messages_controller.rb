class Users::MessagesController < Users::ProjectsController
  
  def new
    @project = Project.find(params[:project_id])
    @message = Message.new()
  end

  def create
    @message = Message.new(message_params)
    @message.projegt_id = "1"
    @message.save
    redirect_to users_user_project_path params[:user_id],params[:project_id]
  end


  private
  def message_params
    params.require(:message).permit(:message_detail)
  end
end