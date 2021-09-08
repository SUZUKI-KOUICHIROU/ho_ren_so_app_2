class Users::UsersController < Users::UserBaseController

  def show
    @user = User.find(params[:id])
  end

end
