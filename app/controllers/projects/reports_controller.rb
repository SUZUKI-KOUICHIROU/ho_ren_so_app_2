class Projects::ReportsController < BaseController
  
  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @qlist = @project.form_display_orders
  end

  def create
    @user = current_user
    @project = Project.find(params[:project_id])
    @qlist = @project.form_display_orders
    cnt = 0
    cnt_check = 0
    @qlist.each do |qt|
        case qt.form_table_type
        when 'text_field'
          buf = qt.text_field.text_field_contents.new(text_field_value: params[:answer][cnt][:answer])
        when 'text_area'
          buf = qt.text_area.text_area_contents.new(text_area_value: params[:answer][cnt][:answer])
        when 'radio_button'
          buf = qt.radio_button.radio_button_contents.new(radio_button_value: params[:answer][cnt][:answer])
        when 'check_box'
          buf = qt.check_box.check_box_contents.new(check_box_value: params[:answer][cnt][:answer])
        when 'select'
          buf = qt.select.select_contents.new(select_value: params[:":checkbox"][cnt])
          cnt_check += 1
        end
      cnt += 1
      buf.save
    end
    flash[:seccess] = "報告を登録しました。"
    redirect_to user_project_path(@user, @project)
  end

  def index
    @user = current_user
    @project = Project.find(params[:project_id])
    @qlist = @project.form_display_orders
  end

  def show
    @user = current_user
    @project = Project.find(params[:project_id])
    buf = @project.form_display_orders.find(params[:id])
    @answers = case buf.form_table_type
      when 'text_field' then buf.text_field.text_field_contents.all 
      when 'text_area' then buf.text_area.text_area_contents.all 
      when 'radio_button' then buf.radio_button.radio_button_contents.all
    end
  end
end
