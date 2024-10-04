class Projects::CounselingsController < Projects::BaseProjectController
  require 'csv'
  before_action :project_authorization
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    clear_session # 一覧画面に戻ってきた際ｾｯｼｮﾝをｸﾘｱするため追加
    set_project_and_members
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @counselings = all_counselings
    @you_addressee_counselings = you_addressee_counselings
    save_counseling_ids_to_session
    counselings_by_search
    respond_to do |format|
      format.html
      format.js
      format.csv { index_export_csv }
    end
  end

  def show
    set_project_and_members
    @counseling = Counseling.find_by(id: params[:id])
    @reply = @counseling.counseling_replies.new
    @counseling_replies = @counseling.counseling_replies.all.order(:created_at)
    if @counseling.nil?
      flash[:alert] = "相談は削除されました。"
      redirect_to user_project_counselings_path(@user, @project) # または適切なパスに変更
      return
    end

    @checked_members = @counseling.checked_members
    @counseling_c = @counseling.counseling_confirmers.find_by(counseling_confirmer_id: current_user)
  end

  def new
    set_project_and_members
    @counseling = @project.counselings.new
  end

  def edit
    set_project_and_members
    @counseling = @project.counselings.find(params[:id])
  end

  # rubocopを一時的に無効にする。
  # rubocop:disable Metrics/AbcSize
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
  # rubocop:enable Metrics/AbcSize

  def update
    set_project_and_members
    @counseling = @project.counselings.find(params[:id])

    if update_counseling_and_confirmers
      send_edited_notification_emails

      flash[:success] = "相談内容を更新しました。"
      redirect_to user_project_counselings_path
    else
      log_errors # ｴﾗｰを表示するﾒｿｯﾄﾞ
      render :edit
    end
  end

  def destroy
    set_project_and_members
    @counseling = Counseling.find(params[:id])
    if @counseling.destroy
      flash[:success] = "「#{@counseling.title}」を削除しました。"
    else
      flash[:danger] = "#{@counseling.title}の削除に失敗しました。"
    end
    redirect_to user_project_counselings_path(@user, @project)
  end

  # "確認しました"フラグの切り替え。機能を確認してもらい、実装確定後リファクタリング
  def read
    @project = Project.find(params[:project_id])
    @counseling = Counseling.find(params[:id])
    @counseling_c = @counseling.counseling_confirmers.find_by(counseling_confirmer_id: current_user)
    @counseling_c.switch_read_flag
    @checked_members = @counseling.checked_members
  end

  def export_csv
    case params[:csv_type]
    when "you_addressee_counselings"
      counseling_ids = session[:you_addressee_counseling_ids]
    when "all_counselings"
      counseling_ids = session[:all_counseling_ids]
    else
      counseling_ids = []
    end
    if counseling_ids.present?
      counselings = Counseling.where(id: counseling_ids)
      send_counselings_csv(counselings)
    else
      send_counselings_csv([])
    end
  end

  # 相談履歴
  def history
    set_project_and_members
    @counseling = @project.counselings
    @counseling_history = all_counselings_history_month
    @counselings_by_search = counseling_search_params.to_h
    all_counselings_history_month
    counselings_history_by_search
    respond_to do |format|
      format.html
      format.csv do |_csv|
        send_counselings_csv(@counseling_history)
      end
    end
  end

  private

  def save_counseling_ids_to_session
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    session[:you_addressee_counseling_ids] = @project.counselings.where(id: you_addressee_counseling_ids).pluck(:id)
    session[:all_counseling_ids] = @project.counselings.pluck(:id)
  end

  def index_export_csv
    case params[:csv_type]
    when "you_addressee_counselings"
      send_counselings_csv(session[:you_addressee_counseling_ids])
    when "all_counselings"
      send_counselings_csv(session[:all_counseling_ids])
    else
      send_counselings_csv([])
    end
  end

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

  # 全員の相談
  def all_counselings
    Counseling.monthly_counselings_for(@project).order(created_at: 'DESC').page(params[:counselings_page]).per(5)
  end

  # あなたへの相談
  def you_addressee_counselings
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    Counseling.monthly_counselings_for(@project).where(id: you_addressee_counseling_ids).order(created_at: 'DESC')
              .page(params[:you_addressee_counselings_page]).per(5)
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

      if send_to_all?
        create_confirmers_for_all_members
      else
        create_confirmers_from_send_to
      end

      true
    else
      false
    end
  end

  def send_to_all?
    ActiveRecord::Type::Boolean.new.cast(params[:counseling][:send_to_all])
  end

  def create_confirmers_for_all_members
    @members.each do |member|
      create_confirmer(member.id)
    end
  end

  def create_confirmers_from_send_to
    @counseling.send_to.each do |t|
      create_confirmer(t)
    end
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
    clear_session_if_search
    if params[:search].present?
      @results = Counseling.search(counseling_search_params)
      if @results.present?
        @counseling_ids = @results.pluck(:id).uniq
        # ﾍﾟｰｼﾞﾈｰｼｮﾝを無視して全ﾃﾞｰﾀを取得
        you_addressee_counselings = @project.counselings
                                            .where(id: @counseling_ids & CounselingConfirmer
                                            .where(counseling_confirmer_id: @user.id)
                                            .pluck(:counseling_id)).order(created_at: 'DESC')
        all_counselings = @project.counselings.where(id: @counseling_ids).order(created_at: 'DESC')
        session_save(you_addressee_counselings, all_counselings) # 検索結果の相談IDをｾｯｼｮﾝに保存
        @counselings = @counselings.where(id: @counseling_ids) if @counselings
        @you_addressee_counselings = @you_addressee_counselings.where(id: @counseling_ids) if @you_addressee_counselings
        session[:previous_search] = params[:search] # 検索条件をｾｯｼｮﾝに保存
      else
        handle_no_results
      end
    end
  end

  # 検索条件が変更された場合ｾｯｼｮﾝをｸﾘｱ
  def clear_session_if_search
    if params[:search].present? && params[:search] != session[:previous_search]
      clear_session
    end
  end

  # ｾｯｼｮﾝをｸﾘｱする共通ﾒｿｯﾄﾞ
  def clear_session
    session[:you_addressee_counseling_ids] = nil
    session[:all_counseling_ids] = nil
  end

  # 検索結果の相談IDをｾｯｼｮﾝに保存 ｲﾝｽﾀﾝｽ変数使用すると検索が機能しなくなるため引数指定
  def session_save(you_addressee_counselings, all_counselings)
    session[:you_addressee_counseling_ids] = you_addressee_counselings.pluck(:id)
    session[:all_counseling_ids] = all_counselings.pluck(:id)
  end

  def handle_no_results
    @you_addressee_counselings = @counselings = Counseling.none
    session[:you_addressee_counseling_ids] = []
    session[:all_counseling_ids] = []
    flash.now[:danger] = '検索結果が見つかりませんでした。'
  end

  # 相談検索(相談履歴)
  def counselings_history_by_search
    if params[:search].present? and params[:search] != ""
      @results = Counseling.search(counseling_search_params)
      if @results.present?
        @counseling_ids = @results.pluck(:id).uniq || @results.pluck(:counseling_id).uniq
        @counseling_history = all_counselings_history.where(id: @counseling_ids)
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。' if @results.blank?
      end
    end
  end

  # 全相談
  def all_counselings_history
    @project.counselings.all.order(created_at: 'DESC').page(params[:page]).per(30)
  end

  # 相談履歴の月検索
  def all_counselings_history_month
    selected_month = params[:month]
    if selected_month.present?
      start_date = Date.parse("#{selected_month}-01")
      end_date = start_date.end_of_month.end_of_day
      counselings = @project.counselings.where(created_at: start_date..end_date).order(created_at: 'DESC').page(params[:page]).per(30)
    else
      counselings = all_counselings_history
    end
    counselings
  end

  # CSVｴｸｽﾎﾟｰﾄ
  def send_counselings_csv(counselings)
    bom = "\uFEFF"
    csv_data = CSV.generate(bom, encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
      column_names = %w(相談者 件名 相談日)
      csv << column_names
      counselings.each do |counseling|
        column_values = [
          counseling.sender_name,
          counseling.title,
          counseling.created_at.strftime("%m月%d日 %H:%M"),
        ]
        csv << column_values
      end
    end
    send_data(csv_data, filename: "相談履歴.csv")
  end
end
