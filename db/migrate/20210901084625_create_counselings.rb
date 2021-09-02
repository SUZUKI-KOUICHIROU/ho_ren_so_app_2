class CreateCounselings < ActiveRecord::Migration[5.2]
  def change
    create_table :counselings do |t|
      t.text :counseling_detail, null: false, default: '' # 相談内容
      t.date :counseling_reply_deadline # 返信期日
      t.text :counseling_reply_detail # 返信内容
      t.boolean :counseling_reply_flag, null: false, default: false # 返信フラグ
      t.references :projegt, foreign_key: true
      t.references :task, foreign_key: true

      t.timestamps
    end
  end
end
