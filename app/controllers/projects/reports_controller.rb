class Projects::ReportsController < BaseController
  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = @project.reports.new(user_id: @user)
    @form_display_orders = @project.form_display_orders.where(using_flag: true)
  end

  def create
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = @project.reports.create(user_id: @user.id)
    @qlist = @project.form_display_orders
    cnt = 1
    @qlist.each do |qt|
      cnt_num = "#{cnt}"
      if params[:answer]
        case qt.form_table_type
        when 'text_field'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.text_field.id, value: params[:answer][cnt_num][:answer])
        when 'text_area'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.text_area.id, value: params[:answer][cnt_num][:answer])
        when 'radio_button'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.radio_button.id, value: params[:answer][cnt_num][:answer])
        when 'check_box'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.check_box.id, array_value: params[:answer][cnt_num])
        when 'select'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.select.id, value: params[:answer][cnt_num][:answer])
        when 'date_field'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.date_field.id, value: params[:answer][cnt_num][:answer])
        end
      end
      cnt += 1
      buf.save
    end
    @report.save
    flash[:seccess] = "報告を登録しました。"
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
    @qlist = @project.form_display_orders
    @reports = @project.reports.order(created_at: 'DESC')
  end

  def show
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = Report.find(params[:id])
    @user = User.find(@report.user_id)
    @answers = @report.answers
  end

  def reject
    @report = Report.find(params[:id])
    @report.update!(params.require(:report).permit(:remanded_reason, :remanded))
    @report.save
    redirect_to action: :show
  end

end
