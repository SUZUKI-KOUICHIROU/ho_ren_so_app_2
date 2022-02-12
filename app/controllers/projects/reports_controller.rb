class Projects::ReportsController < BaseController
  def new
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @projects = @user.projects
    @report = @user.reports.build(project_id: @project.id)
    @answer = @report.answers.build
    @questions = @project.questions.where(using_flag: true)
  end

  def create
    debugger
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @report = @project.reports.new(create_reports_params)
    if @report.save
      flash[:seccess] = '報告を登録しました。'
    else
      flash[:danger] = '報告を登録に失敗しました。'
    end
<<<<<<< HEAD
    @report.save
    @project.report_statuses.find_by(user_id: @user.id, is_newest: true).update(has_submitted: true)
    flash[:seccess] = "報告を登録しました。"
=======
>>>>>>> main
    redirect_to user_project_path(@user, @project)
  end

  def edit
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    @user = User.find(@report.user_id)
    @answers = @report.answers
  end

  def update
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = @project.reports.find(params[:id])
    @answers = @report.answers
    cnt = 1
    @answers.each do |answer|
      cnt_num = "#{cnt}"
      if params[:answer]
        case answer.question_type
        when 'text_field'
          answer.update(value: params[:answer][cnt_num][:value])
        when 'text_area'
          answer.update(value: params[:answer][cnt_num][:value])
        when 'radio_button'
          answer.update(value: params[:answer][cnt_num][:value])
        when 'check_box'
          answer.update(array_value: params[:answer][cnt_num])
        when 'select'
          answer.update(value: params[:answer][cnt_num][:value])
        end
      end
      cnt += 1
    end
    @report.update(remanded: false)
    flash[:seccess] = "報告を編集しました。"
    redirect_to user_project_path(@user, @project)
  end

  def index
    @user = current_user
    @project = Project.find(params[:project_id])
    @qlist = @project.questions
    @reports = @project.reports.order(created_at: 'DESC')
  end

  def show
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    @user = User.find(@report.user_id)
    @answers = @report.answers
  end

  # 再提出を求める。
  def reject
    @report = Report.find(params[:id])
    @report.update!(params.require(:report).permit(:remanded_reason, :remanded))
    @report.save
    redirect_to action: :show
  end

  private

  # フォーム新規登録並びに編集用/create
  def create_reports_params
    params.require(:report).permit(:id, :user_id, :project_id,
                                   answers_attributes: %i[id question_type question_id value array_value])
  end
end
