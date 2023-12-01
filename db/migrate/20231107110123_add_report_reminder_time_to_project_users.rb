class AddReportReminderTimeToProjectUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :project_users, :report_reminder_time, :datetime
  end
end
