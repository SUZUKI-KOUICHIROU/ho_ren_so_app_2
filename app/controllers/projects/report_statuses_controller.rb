class Projects::ReportStatusController < Projects::BaseProjectController

  def send_remind_mail
    @projects = Project.all.include(:report_status)
    @projects.each do |project|
      @members = project.report_statuses.where(deadline: "ここになんらかの条件", submitted: false)
      @members.each do |member| 
        #ここに未報告メンバー催促にメールを送る処理
      end
    end
  end

  def not_send_membelist_mail
    @projects = Project.all.include(:report_status)
    @projects.each do |project|
      @members = project.report_statuses.where(deadline: "ここになんらかの条件", submitted: false)
        #ここに未報告メンバー一覧をリーダーにメールを送る処理
    end
  end
end