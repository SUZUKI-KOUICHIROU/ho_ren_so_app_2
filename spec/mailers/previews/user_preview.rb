# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def send_remind
    UserMailer.send_remind
  end

  def reminder_email
    UserMailer.reminder_email
  end
end
