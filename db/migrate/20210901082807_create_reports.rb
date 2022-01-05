class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.references :project, foreign_key: true
      t.references :task, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :remanded, defalut: false #差し戻し食らったかを管理
      t.string :remanded_reason #要再提出の理由
      t.timestamps
    end
  end
end
