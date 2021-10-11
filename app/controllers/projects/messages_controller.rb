class Projects::MessagesController < BaseController
  
  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @member = @project.users.all
    @message = @project.messages.new()
  end

  def create
    @project = Project.find(params[:project_id])
    @message = @project.messages.new(message_params)
    @message.sender_id = current_user.id
    @message.save
    redirect_to user_project_path params[:user_id],params[:project_id]
  end


  private
  def message_params
    params.require(:message).permit(:message_detail, :title)
  end
end