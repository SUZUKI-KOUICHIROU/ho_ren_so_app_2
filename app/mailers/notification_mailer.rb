class NotificationMailer < ApplicationMailer
  default from: 'celebengineer@gmail.com'

  def send_rework_notification(user)
    @user = user
    mail to: user.email,
      subject: '手直し依頼通知'
  end

  def send_fix_notification(user)
    @user = user
    mail to: user.email,
      subject: '修正完了通知'
  end
end
