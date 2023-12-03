class Projects::MessagesController < Projects::BaseProjectController
  include MessageOperations
  before_action :project_authorization
  before_action :my_message, only: %i[show]

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    @messages = @project.messages.all.order(created_at: 'DESC').page(params[:page]).per(5)
    you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
    @you_addressee_messages = @project.messages.where(id: you_addressee_message_ids).order(created_at: 'DESC').page(params[:page]).per(5)
    you_send_message_ids = Message.where(sender_id: current_user.id).pluck(:id)
    @you_send_messages = @project.messages.where(id: you_send_message_ids).order(created_at: 'DESC').page(params[:page]).per(5)
    set_project_and_members
    @recipient_count = {}
    @messages.each do |message|
      @recipient_count[message.id] = message.message_confirmers.count
    end
    if params[:search].present? and params[:search] != ""
      @results = Message.search(message_search_params)
      if @results.present?
        @message_ids = @results.pluck(:id).uniq
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。'
        return
      end
      @messages = @messages.where(id: @message_ids)
      @you_addressee_messages = @you_addressee_messages.where(id: @message_ids)
      @you_send_messages = @you_send_messages.where(id: @message_ids)
    end
    render :index
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

  def create
    set_project_and_members
    @message = @project.messages.new(message_params)
    @message.sender_id = current_user.id
    @message.sender_name = current_user.name
    save_message_confirmers
  end

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
    delete_old_message_confirmers
    update_message_confirmers
  end

  def destroy
    @user = current_user
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    if @message.destroy
      flash[:success] = "連絡を削除しました。"
    else
      flash[:danger] = "連絡の削除に失敗しました。"
    end
    redirect_to user_project_messages_path(@user, @project)
  end

  private

  def message_search_params
    params.fetch(:search, {}).permit(:created_at, :keywords)
  end

  def message_params
    params.require(:message).permit(:message_detail, :title, :importance, { send_to: [] }, :send_to_all)
  end

  def my_message
    @message = Message.find(params[:id])
    if @message.sender_id != current_user.id && @message.message_confirmers.exists?(message_confirmer_id: current_user.id) == false
      redirect_to root_path
    end
  end

  def save_message_confirmers
    if @message.save
      if params[:message][:send_to_all]
        save_message_and_send_to_members(@message, @members)
        recipients = @members.map { |member| member.email } # メンバーのメールアドレスを取得
      else
        save_message_and_send_to_members(@message, @message.send_to)
        recipients = @message.send_to.map { |send_to| send_to.to_i }.map { |id| @members.find(id).email }
      end
      @message.set_importance(@message.importance, recipients)

      flash[:success] = "連絡内容を送信しました."
      redirect_to user_project_messages_path(current_user, params[:project_id])
    else
      flash[:danger] = "送信相手を選択してください."
      render action: :new
    end
  end

  def delete_old_message_confirmers
    old_message_confirmers = @message.message_confirmers.where.not(message_confirmer_id: @message.send_to)
    old_message_confirmers.destroy_all
  end

  def update_message_confirmers
    if @message.update(message_params)
      if params[:message][:send_to_all]
        save_message_and_send_to_members(@message, @members)
        recipients = @members.map { |member| member.email } # メンバーのメールアドレスを取得
      else
        save_message_and_send_to_members(@message, @message.send_to)
        recipients = @message.send_to.map { |send_to| send_to.to_i }.map { |id| @members.find(id).email }
      end
      @message.set_importance(@message.importance, recipients)
      flash[:success] = "連絡内容を更新し、送信しました。"
      redirect_to user_project_messages_path(current_user, params[:project_id])
    else
      flash[:danger] = "送信相手を選択してください。"
      render :edit
    end
  end
end
