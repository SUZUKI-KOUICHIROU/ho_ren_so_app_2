class BaseController < ApplicationController
  #before_action :authenticate_user!

  # 報告、連絡、相談の一覧を選択されたプロジェクトによって切り替える
  def index_switching
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects.all
    case params[:list_type]
    when 'report'
      @first_question = @project.questions.first
      @report_label_name = @first_question.send(@first_question.form_table_type).label_name
      @reports = @project.reports.where.not(user_id: @user.id).order(update_at: 'DESC').page(params[:page]).per(5)
      @you_reports = @project.reports.where(user_id: @user.id).order(update_at: 'DESC').page(params[:page]).per(5)
    when 'message'
      @messages = @project.messages.all.order(update_at: 'DESC').page(params[:page]).per(5)
      you_addressee_message_ids = MessageConfirmer.where(message_confirmer_id: @user.id).pluck(:message_id)
      @you_addressee_messages = @project.messages.where(id: you_addressee_message_ids).order(update_at: 'DESC').page(params[:page]).per(5)
    when 'counseling'
      @counselings = @project.counselings.all.order(update_at: 'DESC').page(params[:page]).per(5)
      you_addressee_counseling_ids = CounselingConfirmer.where(counseling_confirmer_id: @user.id).pluck(:counseling_id)
      @you_addressee_counselings = @project.counselings.where(id: you_addressee_counseling_ids).order(update_at: 'DESC').page(params[:page]).per(5)
    end
  end
end
