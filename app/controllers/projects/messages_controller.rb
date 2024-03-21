class Projects::MessagesController < Projects::BaseProjectController
  include MessageOperations
  require 'csv'
  before_action :project_authorization
  before_action :my_message, only: %i[show]

  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @messages = all_messages
    @you_addressee_messages = you_addressee_messages
    @you_send_messages = you_send_messages
    count_recipients(@messages)
    messages_by_search
    respond_to do |format|
      format.html
      format.js
    end
    render :index
  end

  def show
    set_project_and_members
    @message = Message.find(params[:id])
    @checked_members = @message.checked_members
    @message_c = @message.message_confirmers.find_by(message_confirmer_id: current_user)
    @reply = @message.message_replies.new
    @message_replies = @message.message_replies.all.order(:created_at)
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

  # 連絡履歴
  def history
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @message = Message.find(params[:id])
    @messages_history = all_messages_history_month
    @messages_by_search = message_search_params.to_h
    count_recipients(@messages_history)
    messages_by_search
    all_messages_history_month
    @messages = @messages_history
    @members = @project.users.all
    messages_by_search
    # formatをhtmlとCSVに振り分ける
    respond_to do |format|
      format.html
      # rubocopを一時的に無効にする。
      # rubocop:disable Lint/UnusedBlockArgument
      format.csv do |csv|
        send_messages_csv(@messages_history)
      end
      # rubocop:enable Lint/UnusedBlockArgument
    end
  end

  private

  # 全員の連絡
  def all_messages
    Message.monthly_messages_for(@project).order(created_at: 'DESC').page(params[:messages_page]).per(5)
  end

  # あなたへの連絡
  def you_addressee_messages
    you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
    Message.monthly_messages_for(@project).where(id: you_addressee_message_ids).order(created_at: 'DESC')
           .page(params[:you_addressee_messages_page]).per(5)
  end

  # あなたが送った連絡
  def you_send_messages
    you_send_message_ids = Message.where(sender_id: current_user.id).pluck(:id)
    Message.monthly_messages_for(@project).where(id: you_send_message_ids).order(created_at: 'DESC')
           .page(params[:you_addressee_messages_page]).per(5)
  end

  # 全連絡
  def all_messages_history
    @project.messages.all.order(created_at: 'DESC').page(params[:messages_page]).per(30)
  end

  # 連絡履歴の月検索
  def all_messages_history_month
    selected_month = params[:month]

    if selected_month.present?
      start_date = Date.parse("#{selected_month}-01")
      end_date = start_date.end_of_month.end_of_day
      messages = @project.messages.where(created_at: start_date..end_date).order(created_at: 'DESC').page(params[:messages_page]).per(30)
    else
      messages = all_messages_history
    end

    messages
  end

  # 連絡した相手をcount
  def count_recipients(messages)
    set_project_and_members
    @recipient_count = {}
    messages.each do |message|
      @recipient_count[message.id] = message.message_confirmers.count
    end
  end

  # 連絡検索
  def messages_by_search
    if params[:search].present? && params[:search] != ""
      @results = Message.search(message_search_params)
      if @results.present?
        @message_ids = @results.pluck(:id).uniq
        @messages = all_messages.where(id: @message_ids)
        @messages_history = all_messages_history.where(id: @message_ids)
        @you_addressee_messages = you_addressee_messages.where(id: @message_ids)
        @you_send_messages = you_send_messages.where(id: @message_ids)
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。' if @results.blank?
      end
    end
  end

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

  # 連絡を送ったメンバーを保存し、メールアドレスと重要度を渡す。
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

  # 連絡更新するにあたり編集前の送信相手を一旦削除する。
  def delete_old_message_confirmers
    old_message_confirmers = @message.message_confirmers.where.not(message_confirmer_id: @message.send_to)
    old_message_confirmers.destroy_all
  end

  # 連絡を送ったメンバーを更新し、メールアドレスと重要度を渡す。
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

  # CSVエクスポート
  def send_messages_csv(messages)
    bom = "\uFEFF"
    csv_data = CSV.generate(bom, encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      column_names = %w(送信者名 タイトル 送信日 受信者 重用度)
      csv << column_names
      messages.each do |message|
        recipient_names = view_context.get_message_recipients(message.id, @members)
        column_values = [
          message.sender_name,
          message.title,
          message.created_at.strftime("%m月%d日 %H:%M"),
          recipient_names,
          message.importance,
        ]
        csv << column_values
      end
    end
    send_data(csv_data, filename: "連絡一覧.csv")
  end
end
