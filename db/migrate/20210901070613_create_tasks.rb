class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :task_name, null: false, default: '' # タスク名
      t.integer :task_rep_id, null: false, default: '' # 担当者のid(userテーブルのid)
      t.integer :task_report_frequency, null: false, default: '' # 報告頻度(x日に1回のx)
      t.date :task_next_report_date, null: false, default: '' # 次回報告日
      t.boolean :task_reported_flag, null: false, default: false # 報告フラグ
      t.references :projegt, foreign_key: true

      t.timestamps
    end
  end
end
