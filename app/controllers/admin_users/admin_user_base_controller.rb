class AdminUsers::AdminUserBaseController < BaseController
  before_action :admin_user

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # 管理権限者を許可
  def admin_user
    return if current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_path
  end
end
