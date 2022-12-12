class RenameProjectNameColumnToProjects < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :project_name, :name
  end
end