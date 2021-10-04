class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.text :report_detail, null: false, default: '' # 報告内容
      t.text :problem_detail # 発生している問題内容
      t.references :project, foreign_key: true
      t.references :task, foreign_key: true

      t.timestamps
    end
  end
end
