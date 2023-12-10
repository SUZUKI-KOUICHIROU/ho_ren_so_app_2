class CreateMessageReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :message_replies do |t|
      t.text :reply_content, null: false, default: ''   # 返信本文
      t.references :message, foreign_key: true          # 連絡ID
      t.integer :poster_id, null: false                 # 投稿者ID
      t.string :poster_name, null: false                # 投稿者名

      t.timestamps
    end
  end
end
