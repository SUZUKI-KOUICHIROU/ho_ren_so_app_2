class AddReportDayToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :report_day, :date
  end
end
