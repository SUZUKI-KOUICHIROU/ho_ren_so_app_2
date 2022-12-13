class Projects::CounselingsController < Projects::BaseProjectController

  def index
    set_project_and_members
    @counselings = @project.counselings.all.order(updated_at: 'DESC').page(params[:page]).per(5)
    you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
    @you_addressee_counselings = @project.counselings.where(id: you_addressee_counseling_ids).order(updated_at: 'DESC').page(params[:page]).per(5)
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

  def create
    set_project_and_members
    @counseling = @project.counselings.new(counseling_params)
    @counseling.sender_id = current_user.id
    @counseling.sender_name = current_user.name
    #ActiveRecord::Type::Boolean：値の型をboolean型に変更
    if ActiveRecord::Type::Boolean.new.cast(params[:counseling][:send_to_all])
      #TO ALLが選択されている時
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
      #TO ALLが選択されていない時
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

end
