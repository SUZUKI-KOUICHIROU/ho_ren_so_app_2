class AddColumnToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :report_read_flag, :boolean
  end
end
