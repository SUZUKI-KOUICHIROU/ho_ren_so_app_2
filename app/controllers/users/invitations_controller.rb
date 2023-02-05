class Users::InvitationsController < BaseController
  # before_action :get_user,         only: [:edit, :update]
  # before_action :valid_user,       only: [:edit, :update]
  # before_action :check_expiration, only: [:edit, :update]

  def new
    @user = User.find(current_user.id)
    @project = Project.find(params[:project_id])
  end

  def create
    @project = Project.find(params[:project_id])
    if params[:invitee][:email].blank?
      flash[:danger] = 'メールアドレスを入力してください。'
      render 'new'
    else
      if User.exists?(email: params[:invitee][:email])
        @user = User.find_by(email: params[:invitee][:email])
        @user.update(invited_by: params[:invitee][:leader_id])
      else
        require 'securerandom'
        mypassword = SecureRandom.alphanumeric.downcase
        # mypassword = Devise.friendly_token.first(10) # 半角小大英数記号生成
        @user = User.new(name: "", email: params[:invitee][:email].downcase, password: mypassword,
                         invited_by: current_user.id, has_editted: false)
        @user.save!(validate: false) # 招待ユーザーの初期ネームを空欄にするためにバリデーションを無視
      end
      @join = Join.create(project_id: @project.id, user_id: @user.id)
      @user.send_invite_email(@join.token, @project.name, mypassword)
      flash[:success] = '招待メールを送信しました！'
    end
    redirect_to user_project_path(current_user, @project)
  end

  def edit
    @user.name = nil if @user
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.activate
      log_in @user
      inviter = User.find(@user.invited_by)
      @user.follow(inviter)
      inviter.follow(@user)
      flash[:success] = 'ようこそ01Booksへ!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  # beforeフィルタ

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    unless @user && !@user.activated? &&
           @user.authenticated?(:invite, params[:id]) # params[:id]はメールアドレスに仕込まれたトークン
      flash[:danger] = '無効なリンクです。'
      redirect_to root_url
    end
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    if @user.invitation_expired?
      flash[:danger] = '招待メールの有効期限が切れています。'
      redirect_to root_url
    end
  end
end
