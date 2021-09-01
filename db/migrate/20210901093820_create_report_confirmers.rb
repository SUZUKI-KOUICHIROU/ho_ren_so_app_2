class CreateReportConfirmers < ActiveRecord::Migration[5.2]
  def change
    create_table :report_confirmers do |t|
      t.integer :report_confirmer_id, null: false, default: '' # 報告されたユーザーのid(userテーブルのid)
      t.boolean :report_confirmation_flag, null: false, default: false  # 確認フラグ
      t.references :report, foreign_key: true

      t.timestamps
    end
  end
end
