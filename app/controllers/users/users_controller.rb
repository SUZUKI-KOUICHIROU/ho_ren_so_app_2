class Users::UsersController < Users::UserBaseController
  # ユーザー詳細ページ表示アクション
  def show
    @user = User.find(params[:id])
  end
end
