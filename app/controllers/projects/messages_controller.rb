class Projects::MessagesController < Projects::BaseProjectController
  before_action :my_message, only: %i[show]

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    @messages = @project.messages.all.order(updated_at: 'DESC').page(params[:page]).per(5)
    you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
    @you_addressee_messages = @project.messages.where(id: you_addressee_message_ids).order(updated_at: 'DESC').page(params[:page]).per(5)
    you_send_message_ids = Message.where(sender_id: current_user.id).pluck(:id)
    @you_send_messages = @project.messages.where(id: you_send_message_ids).order(updated_at: 'DESC').page(params[:page]).per(5)
    set_project_and_members
    @recipients = @members
    @recipients_names = @recipients.map(&:name).join(', ')
  end
  # rubocop:enable Metrics/AbcSize

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

  def edit
    @user = current_user
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    set_project_and_members
  end

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def create
    set_project_and_members
    @message = @project.messages.new(message_params)
    @message.sender_id = current_user.id
    @message.sender_name = current_user.name
    # ActiveRecord::Type::Boolean：値の型をboolean型に変更
    if params[:message][:send_to_all]
      # TO ALLが選択されているとき
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
      # TO ALLが選択されていない時
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
  # rubocop:enable Metrics/AbcSize

  # "確認しました"フラグの切り替え。機能を確認してもらい、実装確定後リファクタリング
  def read
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
    @message_c.switch_read_flag
    @checked_members = @message.checked_members
  end

  def update
    @user = current_user
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    set_project_and_members
    @message.update(message_params)
    flash[:success] = "連絡を更新しました。"
    redirect_to user_project_message_path(@user, @project, @message)
  end

  def destroy
    @user = current_user
    @project = Message.find(params[:project_id])
    @message = Message.find(params[:id])
    if @message.destroy
      flash[:success] = "連絡を削除しました。"
    else
      flash[:danger] = "連絡の削除に失敗しました。"
    end
    redirect_to user_project_messages_path(@user, @project)
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
