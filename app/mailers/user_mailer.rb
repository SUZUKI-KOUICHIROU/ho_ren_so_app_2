class UserMailer < ApplicationMailer


  def invitation(user)
    @user = user
    @inviter = User.find(@user.invited_by)
    mail to: @user.email, subject: "#{@inviter.name}が01Booksに招待しています。"
  end

end