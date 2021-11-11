class Projects::MessagesController < Projects::BaseProjectController

  def create
    @project = Project.find(params[:project_id])
    @message = @project.messages.new(message_params)
    @message.sender_id = current_user.id
    @message.save
    @message.send_to.each do |t|
      @send = @message.message_confirmers.new(message_confirmer_id: t)
      @send.save
    end
    redirect_to project_path params[:project_id]
  end

  def index
    @project = Project.find(params[:project_id])
    @member = @project.users.all
    @messages = @project.messages.my_messages(current_user)
  end

  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @member = @project.users.all
    @message = @project.messages.new()
  end

  def show
    @project = Project.find(params[:project_id])
    @members = @project.users.all
    @message = Message.find(params[:id])
    @checkers = @message.checkers
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
  end

  def read
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
    @message_c.switch_read_flag
    @checkers = @message.checkers
  end

  private
  def message_params
    params.require(:message).permit(:message_detail, :title, { send_to: [] })
  end
end