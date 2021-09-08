class Users::UserBaseController < BaseController
  before_action :correct_user

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # ユーザーがログイン済みユーザーであればtrueを返す。
  def current_user?(user)
    user == current_user
  end

  # 管理権限者、または現在ログイン済みユーザーを許可
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_path
  end

  # ログイン済みユーザーを許可
  def correct_user
    return if current_user?(@user)

    flash[:danger] = '権限がありません。'
    redirect_to root_path
  end
end
