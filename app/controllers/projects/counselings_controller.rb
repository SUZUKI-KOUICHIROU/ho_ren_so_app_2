class Projects::CounselingsController < Projects::BaseProjectController
  def index
    set_project_and_members
    @counselings = @project.counselings.all.order(created_at: 'DESC').page(params[:page]).per(5)
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    @you_addressee_counselings = @project.counselings.where(id: you_addressee_counseling_ids).order(created_at: 'DESC').page(params[:page]).per(5)
  end

  def show
    set_project_and_members
    @counseling = Counseling.find(params[:id])
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
        end
        flash[:success] = "相談内容を送信しました。"
        redirect_to user_project_path current_user, params[:project_id]
      else
        flash[:danger] = "送信相手を選択してください。"
        render action: :new
      end
    else
      # TO ALLが選択されていない時
      if @counseling.save
        @counseling.send_to.each do |t|
          @send = @counseling.counseling_confirmers.new(counseling_confirmer_id: t)
          @send.save
        end
        flash[:success] = "相談内容を送信しました。"
        redirect_to user_project_path current_user, params[:project_id]
      else
        flash[:danger] = "送信相手を選択してください。"
        render action: :new
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    set_project_and_members
    @counseling = @project.counselings.find(params[:id])

    if update_counseling_and_confirmers
      flash[:success] = "相談内容を更新しました。"
      redirect_to user_project_counselings_path
    else
      flash[:danger] = "送信相手を選択してください。"
      render action: :edit
    end
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
    params.require(:counseling).permit(:counseling_detail, :title, { send_to: [] }, :send_to_all)
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
end
