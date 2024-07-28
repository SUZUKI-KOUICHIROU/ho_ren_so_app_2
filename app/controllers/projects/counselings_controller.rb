# app/controllers/projects/counselings_controller.rb

class Projects::CounselingsController < Projects::BaseProjectController
  require 'csv'

  before_action :project_authorization
  before_action :authorize_user!, only: %i[edit update destroy]

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
    render :index
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
    set_project_and_members
    unless params[:counseling][:images].nil?
      set_enable_images(params[:counseling][:image_enable], params[:counseling][:images])
    end
    @counseling = @project.counselings.new(counseling_params)
    @counseling.sender_id = current_user.id
    @counseling.sender_name = current_user.name
    # ActiveRecord::Type::Boolean：値の型をboolean型に変更
    if ActiveRecord::Type::Boolean.new.cast(params[:counseling][:send_to_all])
      # TO ALLが選択されている時
      if @counseling.save
        @members.each do |member|
          @send = @counseling.counseling_confirmers.new(counseling_confirmer_id: member.id)
          @send.save
          @user = member
          CounselingMailer.notification(@user, @counseling, @project).deliver_now
        end
        flash[:success] = "相談内容を送信しました。"
        redirect_to user_project_path current_user, params[:project_id]
      else
        log_errors # ｴﾗｰを表示するﾒｿｯﾄﾞ
        render :new
      end
    else
      # TO ALLが選択されていない時
      if @counseling.save
        @counseling.send_to.each do |t|
          @send = @counseling.counseling_confirmers.new(counseling_confirmer_id: t)
          @send.save
          @user = User.find(t)
          CounselingMailer.notification(@user, @counseling, @project).deliver_now
        end
        flash[:success] = "相談内容を送信しました。"
        redirect_to user_project_path current_user, params[:project_id]
      else
        log_errors # ｴﾗｰを表示するﾒｿｯﾄﾞ
        render :new
      end
    end
  end

  def update
    @counseling = @project.counselings.find(params[:id])
    if @counseling.update(counseling_params)
      send_edited_notification_emails
      flash[:success] = "相談内容を更新しました。"
      redirect_to user_project_counseling_path(@user, @project, @counseling)
    else
      log_errors # ｴﾗｰを表示するﾒｿｯﾄﾞ
      render :edit
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

  def log_errors # ｴﾗｰを表示
    if @counseling.errors.full_messages.present? # counselingのerrorが存在する時
      flash[:danger] = @counseling.errors.full_messages.join(", ") # ｴﾗｰのﾒｯｾｰｼﾞを表示 複数ある時は連結して表示
    end
  end

  def authorize_user!
    counseling = @project.counselings.find(params[:id])
    unless current_user.id == counseling.sender_id
      flash[:alert] = "アクセス権限がありません"
      redirect_to user_project_counselings_path(@user, @project)
      # redirect先をrootとするとﾘﾀﾞｲﾚｸﾄﾙｰﾌﾟ発生するため相談一覧とした
    end
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

  def handle_counseling_sending
    if ActiveRecord::Type::Boolean.new.cast(params[:counseling][:send_to_all])
      # Send notification to all users
      @project.users.each do |member|
        CounselingMailer.notification(member, @counseling).deliver_now
      end
    else
      # Send notification to selected users
      @counseling.send_to.each do |recipient_id|
        recipient = User.find(recipient_id)
        CounselingMailer.notification(recipient, @counseling).deliver_now
      end
    end
  end

  def send_edited_notification_emails
    if ActiveRecord::Type::Boolean.new.cast(params[:counseling][:send_to_all])
      @project.users.each do |member|
        CounselingMailer.notification_edited(member, @counseling).deliver_now
      end
    else
      @counseling.send_to.each do |recipient_id|
        recipient = User.find(recipient_id)
        CounselingMailer.notification_edited(recipient, @counseling).deliver_now
      end
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
      column_names = %w(送信者名 タイトル 送信日 受信者)
      csv << column_names
      counselings.each do |counseling|
        recipient_names = view_context.get_counseling_recipients(counseling.id, @members)
        column_values = [
          counseling.sender_name,
          counseling.title,
          counseling.created_at.strftime("%m月%d日 %H:%M"),
          recipient_names,
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
