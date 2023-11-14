class CounselingMailer < ApplicationMailer

  def notification(user, counseling, project, token)
    @user = user
    @counseling = counseling
    @project = project
    @token = token
    @project_name = project.name
    @sender_name = User.find(@counseling.sender_id).name
    @counseling_title = counseling.title
    
    mail(to: @user.email, subject: '相談が届きました')
  end
end