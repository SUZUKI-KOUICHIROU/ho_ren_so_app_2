# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def send_remind
    UserMailer.send_remind
  end
end
