class CreateCounselings < ActiveRecord::Migration[5.2]
  def change
    create_table :counselings do |t|
      t.text :counseling_detail, null: false, default: '' # 相談内容
      t.date :counseling_reply_deadline # 返信期日
      t.references :project, foreign_key: true
      t.integer :sender_id #送信者のID
      t.string :sender_name #送信者名
      t.string :title #件名
      t.timestamps
    end
  end
end
