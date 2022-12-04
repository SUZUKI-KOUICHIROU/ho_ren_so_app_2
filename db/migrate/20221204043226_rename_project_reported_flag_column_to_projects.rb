class RenameProjectReportedFlagColumnToProjects < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :project_reported_flag, :reported_flag
  end
end
