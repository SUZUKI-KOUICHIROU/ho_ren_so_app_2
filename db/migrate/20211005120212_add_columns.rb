class AddColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :description, :string # プロジェクト概要
    add_column :messages, :sender_id, :integer # メッセージ送信者のid
    add_column :messages, :title, :string # メッセージタイトル
  end
end
