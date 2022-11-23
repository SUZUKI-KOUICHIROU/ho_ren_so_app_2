class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :project_name, null: false, default: '' # プロジェクト名
      t.integer :project_leader_id, null: false # プロジェクトリーダーのid(userテーブルのid)
      t.integer :project_report_frequency, null: false, default: 1 # 報告頻度(x日に1回のx)
      t.date :project_next_report_date, null: false # 次回報告日
      t.boolean :project_reported_flag, null: false, default: false # 報告フラグ
      t.string :description #プロジェクトの概要
      t.timestamps
    end
  end
end
