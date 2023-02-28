class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false, default: '' # プロジェクト名
      t.integer :leader_id, null: false # プロジェクトリーダーのid(userテーブルのid)
      t.integer :report_frequency, null: false, default: 1 # 報告頻度(x日に1回のx)
      t.date :next_report_date, null: false # 次回報告日
      t.boolean :reported_flag, null: false, default: false # 報告フラグ
      t.string :description #プロジェクトの概要
      t.timestamps
    end
  end
end
