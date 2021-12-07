class Projects::ReportsController < BaseController
  
  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = @project.reports.new(user_id: @user)
    @qlist = @project.form_display_orders
  end

  # def create
  #   @user = current_user
  #   @project = Project.find(params[:project_id])
  #   @report = @project.reports.create(user_id: @user)
  #   @qlist = @project.form_display_orders
  #   cnt = 0
  #   cnt_check = 0
  #   @qlist.each do |qt|
  #       case qt.form_table_type
  #       when 'text_field'
  #         buf = qt.text_field.text_field_contents.new(report_id: @report.id, text_field_value: params[:answer][cnt][:answer])
  #       when 'text_area'
  #         buf = qt.text_area.text_area_contents.new(report_id: @report.id, text_area_value: params[:answer][cnt][:answer])
  #       when 'radio_button'
  #         buf = qt.radio_button.radio_button_contents.new(report_id: @report.id, radio_button_value: params[:answer][cnt][:answer])
  #       when 'check_box'
  #         buf = qt.check_box.check_box_contents.new(report_id: @report.id, check_box_value: params[:answer][cnt][:answer])
  #       when 'select'
  #         buf = qt.select.select_contents.new(report_id: @report.id, select_value: params[:":checkbox"][cnt])
  #         cnt_check += 1
  #       end
  #     cnt += 1
  #     debugger
  #     buf.save
  #   end
  #   @report.save
  #   flash[:seccess] = "報告を登録しました。"
  #   redirect_to user_project_path(@user, @project)
  # end

  def create
    @user = current_user
    @project = Project.find(params[:project_id])
    @report = @project.reports.create(user_id: @user.id)
    @qlist = @project.form_display_orders
    cnt = 0
    cnt_check = 0
    @qlist.each do |qt|
        case qt.form_table_type
        when 'text_field'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.text_field.id, value: params[:answer][cnt][:answer])
        when 'text_area'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.text_area.id, value: params[:answer][cnt][:answer])
        when 'radio_button'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.radio_button.id, value: params[:answer][cnt][:answer])
        when 'check_box'
          debugger
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.check_box.id, array_value: params[:":checkbox"][cnt_check][:answer])
          cnt -= 1
          cnt_check += 1
        when 'select'
          buf = @report.answers.new(question_type: qt.form_table_type, question_id: qt.select.id, value: params[:answer][cnt][:answer])
        end
      cnt += 1
      buf.save
    end
    @report.save
    flash[:seccess] = "報告を登録しました。"
    redirect_to user_project_path(@user, @project)
  end

  def index
    @user = current_user
    @project = Project.find(params[:project_id])
    @qlist = @project.form_display_orders
    @reports = @project.reports.order(created_at: 'DESC')
  end

  def show
    @report = Report.find(params[:id])
    @user = User.find(@report.user_id)
    @answers = @report.answers
  end
end
