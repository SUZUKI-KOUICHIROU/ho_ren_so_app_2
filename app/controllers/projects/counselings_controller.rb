class Projects::CounselingsController < Projects::BaseProjectController
  before_action :project_authorization

  def index
    set_project_and_members
    @counselings = @project.counselings.all.order(created_at: 'DESC').page(params[:counselings_page]).per(5)
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    @you_addressee_counselings = @project.counselings
                                         .where(id: you_addressee_counseling_ids)
                                         .order(created_at: 'DESC')
                                         .page(params[:you_addressee_counselings_page])
                                         .per(5)
    respond_to do |format|
      format.html
      format.js
    end
    counselings_by_search
    respond_to do |format|
      format.html
      format.js
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
        log_and_render_errors # ｴﾗｰを表示するﾒｿｯﾄﾞ
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
        log_and_render_errors # ｴﾗｰを表示するﾒｿｯﾄﾞ
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
      flash[:danger] = "送信相手を選択してください。"
      render action: :edit
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

  private

  def counseling_params
    params.require(:counseling).permit(:counseling_detail, :title, { send_to: [] }, :send_to_all, images: [])
  end

  def log_and_render_errors # ｴﾗｰを表示
    if @counseling.errors.full_messages.present? # counselingのerrorが存在する時
      flash[:danger] = @counseling.errors.full_messages.join(", ") # ｴﾗｰのﾒｯｾｰｼﾞを表示 複数ある時は連結して表示
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
    if params[:search].present? and params[:search] != ""
      @results = Counseling.search(counseling_search_params)
      if @results.present?
        @counseling_ids = @results.pluck(:id).uniq
      else
        flash.now[:danger] = '検索結果が見つかりませんでした。'
        return
      end
      @counselings = @counselings.where(id: @counseling_ids) if @counselings
      @you_addressee_counselings = @you_addressee_counselings.where(id: @counseling_ids) if @you_addressee_counselings
    end
  end
end
