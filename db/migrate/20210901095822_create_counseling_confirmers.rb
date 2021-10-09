class CreateCounselingConfirmers < ActiveRecord::Migration[5.2]
  def change
    create_table :counseling_confirmers do |t|
      t.integer :counseling_confirmer_id, null: false, default: '' # 相談されたユーザーのid(userテーブルのid)
      t.text :counseling_reply_detail # 返信内容
      t.boolean :counseling_reply_flag, null: false, default: false # 返信フラグ
      t.boolean :counseling_confirmation_flag, null: false, default: false  # 確認フラグ
      t.references :counseling, foreign_key: true

      t.timestamps
    end
  end
end
