class RenameProjectReportFrequencyColumnToProjects < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :project_report_frequency, :report_frequency
  end
end
