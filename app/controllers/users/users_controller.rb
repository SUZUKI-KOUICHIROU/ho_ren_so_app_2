class Users::UsersController < Users::BaseUserController
  # ユーザー詳細ページ表示アクション
  def show
    @user = User.find(params[:id])
    @projects = Project.all
  end
end
