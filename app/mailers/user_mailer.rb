class UserMailer < ApplicationMailer


  def invitation(user)
    @user = user
    @inviter = User.find(@user.invited_by)
    
  end

end