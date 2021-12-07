class CreateReportHistory < ActiveRecord::Migration[5.2]
  #報告の済/未済の管理、報告率、未報告者などの集計、通知を目的とする。
  def change
    create_table :report_histories do |t|
      t.references :project, foreign_key: true
      t.integer :user_id #報告者のID
      t.boolean :done, default: false #報告の済/未済
      t.boolean :reminded, default: false #報告催促通知の済/未済
      t.date :deadline #報告期限
    end
  end
end
