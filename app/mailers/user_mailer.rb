class UserMailer < ApplicationMailer
  def invitation(user, token, project_name, password)
    @user = user
    @inviter = User.find(@user.invited_by).user_name
    @token = token
    @project_name = project_name
    @password = password
    mail to: @user.email, subject: "【ホウレンソウアプリ】プロジェクトへの招待のお知らせ"
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