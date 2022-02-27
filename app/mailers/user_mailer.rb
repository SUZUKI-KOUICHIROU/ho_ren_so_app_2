class UserMailer < ApplicationMailer
  def invitation(user, token)
    @user = user
    @inviter = User.find(@user.invited_by)
    @token = token
    mail to: @user.email, subject: "#{@inviter.user_name}が01Booksに招待しています。"
  end
end