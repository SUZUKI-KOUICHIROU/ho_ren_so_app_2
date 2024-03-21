class AddColumnsToProjectUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :project_users, :reminder_enabled, :boolean, default: false
    add_column :project_users, :reminder_days, :integer
    add_column :project_users, :report_time, :time
  end
end
