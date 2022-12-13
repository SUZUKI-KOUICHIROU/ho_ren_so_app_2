class RenameProjectLeaderIdColumnToProjects < ActiveRecord::Migration[5.2]
  def change
    rename_column :projects, :project_leader_id, :leader_id
  end
end
