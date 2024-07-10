class Projects::CounselingsController < Projects::BaseProjectController
  require 'csv'

  before_action :project_authorization
  before_action :set_project_and_members, only: [:index, :show, :new, :edit, :create, :update, :destroy, :read]

  def index
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @counselings = all_counselings
    @you_addressee_counselings = you_addressee_counselings
    @you_send_counselings = you_send_counselings
    count_recipients(@counselings)
    counselings_by_search
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @counseling = Counseling.find_by(id: params[:id])
    if @counseling.nil?
      flash[:alert] = "相談は削除されました。"
      redirect_to user_project_counselings_path(@user, @project)
      return
    end
    @reply = @counseling.counseling_replies.new
    @counseling_replies = @counseling.counseling_replies.all.order(:created_at)
    @checked_members = @counseling.checked_members
    @counseling_c = @counseling.counseling_confirmers.find_by(counseling_confirmer_id: current_user)
  end

  def history
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @counseling = Counseling.find(params[:id])
    @counselings_history = all_counselings_history_month
    @mcounselings_by_search = counseling_search_params.to_h
    count_recipients(@counselings_history)
    counselings_by_search
    @members = @project.users.all
    respond_to do |format|
      format.html
      format.csv do
        send_counselings_csv(@counselings_history)
      end
    end
  end

  def new
    @counseling = @project.counselings.new
  end

  def edit
    @counseling = @project.counselings.find(params[:id])
  end

  def create
    @counseling = @project.counselings.new(counseling_params)
    @counseling.sender_id = current_user.id
    @counseling.sender_name = current_user.name
    handle_counseling_sending
  end

  def update
    @counseling = @project.counselings.find(params[:id])
    if update_counseling_and_confirmers
      send_edited_notification_emails
      flash[:success] = "相談内容を更新しました。"
      redirect_to user_project_counselings_path
    else
      flash[:danger] = "送信相手を選択してください。"
      render action: :edit
    end
  end

  def destroy
    @counseling = Counseling.find(params[:id])
    if @counseling.destroy
      flash[:success] = "「#{@counseling.title}」を削除しました。"
    else
      flash[:danger] = "#{@counseling.title}の削除に失敗しました。"
    end
    redirect_to user_project_counselings_path(@user, @project)
  end

  def read
    @counseling = Counseling.find(params[:id])
    @counseling_c = @counseling.counseling_confirmers.find_by(counseling_confirmer_id: current_user)
    @counseling_c.switch_read_flag
    @checked_members = @counseling.checked_members
  end

  private

  def counseling_params
    params.require(:counseling).permit(:counseling_detail, :title, { send_to: [] }, :send_to_all, images: [])
  end

  def counseling_search_params
    if params[:search].is_a?(ActionController::Parameters)
      params.require(:search).permit(:created_at, :keywords)
    elsif params[:search].is_a?(String)
      { keywords: params[:search] }
    else
      {}
    end
  end

  def update_counseling_and_confirmers
    if @counseling.update(counseling_params)
      @counseling.counseling_confirmers.destroy_all
      send_to_all? ? create_confirmers_for_all_members : create_confirmers_from_send_to
      true
    else
      false
    end
  end

  def send_to_all?
    ActiveRecord::Type::Boolean.new.cast(params[:counseling][:send_to_all])
  end

  def create_confirmers_for_all_members
    @members.each { |member| create_confirmer(member.id) }
  end

  def create_confirmers_from_send_to
    @counseling.send_to.each { |t| create_confirmer(t) }
  end

  def create_confirmer(confirmer_id)
    @counseling.counseling_confirmers.create(counseling_confirmer_id: confirmer_id)
  end

  def send_edited_notification_emails
    recipients = @counseling.send_to_all ? @members : @counseling.send_to
    recipients.each do |recipient|
      recipient = recipient.is_a?(User) ? recipient : User.find(recipient)
      CounselingMailer.notification_edited(recipient, @counseling, @project).deliver_now
    end
  end

  def counselings_by_search
    if params[:search].present? && params[:search] != ""
      @results = Counseling.search(counseling_search_params)
      if @results.present?
        @counseling_ids = @results.pluck(:id).uniq
        @counselings = all_counselings.where(id: @counseling_ids)
        @counselings_history = all_counselings_history.where(id: @counseling_ids)
        @you_addressee_counselings = you_addressee_counselings.where(id: @counseling_ids)
        @you_send_counselings = you_send_counselings.where(id: @counseling_ids)
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。'
      end
    end
  end

  def send_counselings_csv(counselings)
    bom = "\uFEFF"
    csv_data = CSV.generate(bom, encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      column_names = %w(送信者名 タイトル 送信日 受信者 重用度)
      csv << column_names
      counselings.each do |counseling|
        recipient_names = view_context.get_counseling_recipients(counseling.id, @members)
        column_values = [
          counseling.sender_name,
          counseling.title,
          counseling.created_at.strftime("%m月%d日 %H:%M"),
          recipient_names,
          counseling.importance,
        ]
        csv << column_values
      end
    end
    send_data(csv_data, filename: "相談一覧.csv")
  end

  def all_counselings
    Counseling.monthly_counselings_for(@project).order(created_at: 'DESC').page(params[:counselings_page]).per(5)
  end

  def you_addressee_counselings
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    Counseling.monthly_counselings_for(@project)
              .where(id: you_addressee_counseling_ids)
              .order(created_at: 'DESC')
              .page(params[:you_addressee_counselings_page])
              .per(5)
  end

  def you_send_counselings
    you_send_counseling_ids = Counseling.where(sender_id: current_user.id).pluck(:id)
    Counseling.monthly_counselings_for(@project)
              .where(id: you_send_counseling_ids)
              .order(created_at: 'DESC')
              .page(params[:you_send_counselings_page])
              .per(5)
  end

  def all_counselings_history
    @project.counselings.all.order(created_at: 'DESC').page(params[:counselings_page]).per(30)
  end

  def all_counselings_history_month
    selected_month = params[:month]
    if selected_month.present?
      start_date = Date.parse("#{selected_month}-01")
      end_date = start_date.end_of_month.end_of_day
      @project.counselings.where(created_at: start_date..end_date).order(created_at: 'DESC').page(params[:counselings_page]).per(30)
    else
      all_counselings_history
    end
  end

  def count_recipients(counselings)
    @recipient_count = {}
    counselings.each do |counseling|
      @recipient_count[counseling.id] = counseling.counseling_confirmers.count
    end
  end
end