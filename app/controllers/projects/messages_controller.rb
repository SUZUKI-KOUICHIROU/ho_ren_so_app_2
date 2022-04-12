class Projects::MessagesController < Projects::BaseProjectController
  before_action :my_message, only: %i[show]

  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    @messages = @project.messages.all.order(update_at: 'DESC').page(params[:page]).per(5)
    you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
    @you_addressee_messages = @project.messages.where(id: you_addressee_message_ids).order(update_at: 'DESC').page(params[:page]).per(5)
  end

  def show
    set_project_and_members
    @message = Message.find(params[:id])
    @checked_members = @message.checked_members
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
  end

  def new
    set_project_and_members
    @message = @project.messages.new
  end

  def create
    set_project_and_members
    @message = @project.messages.new(message_params)
    @message.sender_id = current_user.id
    @message.sender_name = current_user.user_name
    #ActiveRecord::Type::Boolean：値の型をboolean型に変更
    if ActiveRecord::Type::Boolean.new.cast(params[:message][:send_to_all])
      #TO ALLが選択されているとき
      if @message.save
        @members.each do |member|
          @send = @message.message_confirmers.new(message_confirmer_id: member.id)
          @send.save
        end
        flash[:success] = "連絡内容を送信しました。"
        redirect_to user_project_path current_user, params[:project_id]
      else
        flash[:danger] = "送信相手を選択してください。"
        render action: :new
      end
    else
      #TO ALLが選択されていない時
      #debugger
      if @message.save
        @message.send_to.each do |t|
          @send = @message.message_confirmers.new(message_confirmer_id: t)
          @send.save
        end
        flash[:success] = "連絡内容を送信しました。"
        redirect_to user_project_path current_user, params[:project_id]
      else
        flash[:danger] = "送信相手を選択してください。"
        render :new
      end
    end
  end
  # "確認しました"フラグの切り替え。機能を確認してもらい、実装確定後リファクタリング
  def read
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
    @message_c.switch_read_flag
    @checked_members = @message.checked_members
  end

  private

  def message_params
    params.require(:message).permit(:message_detail, :title, { send_to: [] }, :send_to_all)
  end

  def my_message
    @message = Message.find(params[:id])
    if @message.sender_id != current_user.id && @message.message_confirmers.exists?(message_confirmer_id: current_user.id) == false
      redirect_to root_path
    end
  end
end
