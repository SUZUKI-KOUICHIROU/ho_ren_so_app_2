class Users::InvitationsController < BaseController

  def new
    @user = current_user
  end

  def create
    if params[:invitee][:email].blank?
      flash[:danger] = "メールアドレスを入力してください。"
      render 'new'
    else
      @user = User.create(user_name: "名無しの招待者", email: params[:invitee][:email].downcase, password: "foobar", invited_by: current_user.id)
      @user.send_invite_email
      flash[:info] = "招待メールを送信しました！"
      redirect_to root_url
    end
  end

  def edit
    @user.user_name = nil if @user
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
      flash[:success] = "ようこそ01Booksへ!"
      redirect_to @user
    else
      render "edit"
    end

  end

  #:invite_tokenを追加。
  attr_accessor :remember_token, :activation_token, :reset_token, :invite_token

  #招待メールを送信する
  def send_invite_email
    UserMailer.invitation(self).deliver_now
  end

  #ユーザー招待の属性（トークンとダイジェストと、招待したユーザーのid）を作成する。
  def create_invite_digest
    self.invite_token = User.new_token
    update_attributes(invite_digest: User.digest(invite_token), invite_sent_at: Time.zone.now)
  end

  #招待の期限が切れている場合はtrueを返す
  def invitation_expired?
    self.invite_sent_at < 24.hours.ago
  end

  private

  def user_params
    params.require(:user).permit(:user_name, :password, :password_confirmation)
  end


  #beforeフィルタ

  def get_user
    @user = User.find_by(email: params[:email])
  end

  #正しいユーザーかどうか確認する
  def valid_user
    unless (@user && !@user.activated? &&
        @user.authenticated?(:invite, params[:id])) #params[:id]はメールアドレスに仕込まれたトークン
      flash[:danger] = "無効なリンクです。"
      redirect_to root_url
    end
  end

  #トークンが期限切れかどうか確認する
  def check_expiration
    if @user.invitation_expired?
      flash[:danger] = "招待メールの有効期限が切れています。"
      redirect_to root_url
    end
  end
end
