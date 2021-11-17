class Projects::ReportsController < BaseController
  
  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @qlist = @project.form_display_orders
  end
end
