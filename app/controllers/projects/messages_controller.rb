class Projects::MessagesController < BaseController
  
  def new
    @project = Project.find(params[:project_id])
    @message = @project.messages.new()
  end

  def create
    @project = Project.find(params[:project_id])
    @message = @project.messages.new(message_params)
    @message.projegt_id = "1"
    @message.save
    redirect_to users_user_project_path params[:user_id],params[:project_id]
  end


  private
  def message_params
    params.require(:message).permit(:message_detail)
  end
end