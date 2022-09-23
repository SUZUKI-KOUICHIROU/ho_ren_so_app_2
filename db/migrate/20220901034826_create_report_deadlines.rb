class CreateReportDeadlines < ActiveRecord::Migration[5.2]
  def change
    create_table :report_deadlines do |t|
      t.date :day
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
