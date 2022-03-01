class UserMailer < ApplicationMailer
  def invitation(user, token, project_name, password)
    @user = user
    @inviter = User.find(@user.invited_by).user_name
    @token = token
    @project_name = project_name
    @password = password
    mail to: @user.email, subject: "【ホウレンソウアプリ】プロジェクトへの招待のお知らせ"
  end
end