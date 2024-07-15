# app/mailers/counseling_mailer.rb

class CounselingMailer < ApplicationMailer
  def notification(user, counseling)
    @user = user
    @counseling = counseling
    @project = counseling.project
    @project_name = @project.name
    @sender_name = counseling.sender.name  # Assuming sender is a User and has a 'name' attribute
    @counseling_title = counseling.title

    mail(to: @user.email, subject: I18n.t('counseling_mailer.consultation_arrived'))
  end

  def notification_edited(user, counseling)
    @user = user
    @counseling = counseling
    @project = counseling.project
    @project_name = @project.name
    @sender_name = counseling.sender.name  # Assuming sender is a User and has a 'name' attribute
    @counseling_title = counseling.title

    mail(to: @user.email, subject: I18n.t('counseling_mailer.consultation_edited_arrived'))
  end
end
