class Users::UsersController < Users::BaseUserController
  # ユーザー詳細ページ表示アクション
  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "ユーザー登録が完了しました"
      UserMailer.send_when_signup(@user).deliver
      redirect_to("/users/#{@user.id}")
    else
      render("users/new")
    end
  end
end
