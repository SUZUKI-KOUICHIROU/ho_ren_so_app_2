class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text :message_detail, null: false, default: '' # 連絡内容
      t.references :project, foreign_key: true
      t.references :task, foreign_key: true

      t.timestamps
    end
  end
end
