class UserMailer < ApplicationMailer
  def invitation(user, token)
    @user = user
    @inviter = User.find(@user.invited_by)
    @token = token
    mail to: @user.email, subject: "#{@inviter.user_name}がグループに招待しています。"
  end

  # プロジェクト内の未報告メンバーをリーダーに報告
  def notice_not_submitted_members(project_name,users,to_address)
    @project_name = project_name
    @users = users
    mail to: to_address, subject: "#{project_name}未報告者のご連絡"
  end

  # 未報告メンバーにリマインドメールを送信
  def send_remind(project_name,to_address)
    @project = project_name
    mail to: to_address, subject: "【リマインド】#{project_name}の報告期限が迫っています。"
  end
end