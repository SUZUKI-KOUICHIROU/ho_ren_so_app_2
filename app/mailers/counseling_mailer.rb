class CounselingMailer < ApplicationMailer
  def notification(user, counseling, project)
    @user = user
    @counseling = counseling
    @project = project
    @project_name = project.name
    @sender_name = User.find(@counseling.sender_id).name
    @counseling_title = counseling.title

    mail(to: @user.email, subject: I18n.t('counseling_mailer.consultation_arrived'))
  end

  def notification_edited(user, counseling, project)
    @user = user
    @counseling = counseling
    @project = project
    @project_name = project.name
    @sender_name = User.find(@counseling.sender_id).name
    @counseling_title = counseling.title

    mail(to: @user.email, subject: I18n.t('counseling_mailer.consultation_edited_arrived'))
  end
end
