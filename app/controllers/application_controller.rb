class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # このアクションを追加
  def after_sign_in_path_for(resource)
    "/user/#{current_user.id}"
  end

  protected

  # 入力フォームからアカウント名情報をDBに保存するために追加
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # ユーザーがログイン済みユーザーであればtrueを返す。
  def current_user?(user)
    user == current_user
  end

  # ログイン済みユーザーを許可
  def correct_user
    return if current_user?(@user)

    flash[:danger] = '権限がありません。'
    redirect_to(root_url)
  end

  # 管理権限者を許可
  def admin_user
    return if current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  # 管理権限者、または現在ログイン済みユーザーを許可
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to(root_url)
  end
end
