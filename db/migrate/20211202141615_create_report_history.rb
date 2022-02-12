class CreateReportHistory < ActiveRecord::Migration[5.2]
  #報告の期日、報告済/未を管理。報告率、未報告者などの集計、通知に使用したい。
  def change
    create_table :report_statuses do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :has_submitted, default: false #報告の済/未済
      t.boolean :has_reminded, default: false #報告催促通知の済/未済
      t.date :deadline #報告期日
      t.boolean :is_newest, default: true # この報告期日が最新のものか
    end
  end
end
