class Projects::MessagesController < BaseController
  def create
    unless params[:send_to].nil?
      @project = Project.find(params[:project_id])
      @message = @project.messages.new(message_params)
      @message.sender_id = current_user.id
      @message.save
      debugger
      @message.send_to.each do |t|
        @send = @message.message_confirmers.new(message_confirmer_id: t)
        @send.save
      end
      redirect_to user_project_path current_user, params[:project_id]
    else
      flash[:danger] = "送信相手を選択してください。"
      redirect_to
    end
  end

  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    @messages = @project.messages.all.order(update_at: 'DESC').page(params[:page]).per(5)
    you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
    @you_addressee_messages = @project.messages.where(id: you_addressee_message_ids).order(update_at: 'DESC').page(params[:page]).per(5)
  end

  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @member = @project.users.all
    @message = @project.messages.new
  end

  def show
    @user = current_user
    @project = Project.find(params[:project_id])
    @members = @project.users.all
    @message = Message.find(params[:id])
    @checkers = @message.checkers
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
  end

  # "確認しました"フラグの切り替え。機能を確認してもらい、実装確定後リファクタリング
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
