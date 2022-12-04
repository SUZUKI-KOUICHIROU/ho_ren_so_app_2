class RenameProjectNextReportDateColumnToProjects < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :project_next_report_date, :next_report_date
  end
end
