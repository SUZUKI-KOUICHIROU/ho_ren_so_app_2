class CreateMessageConfirmers < ActiveRecord::Migration[5.2]
  def change
    create_table :message_confirmers do |t|
      t.integer :message_confirmer_id, null: false, default: '' # 連絡されたユーザーのid(userテーブルのid)
      t.boolean :message_confirmation_flag, null: false, default: false  # 確認フラグ
      t.references :message, foreign_key: true

      t.timestamps
    end
  end
end
