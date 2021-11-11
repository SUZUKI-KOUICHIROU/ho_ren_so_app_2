class AddColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :description, :string, null: false, default: '' # プロジェクト概要
    add_column :messages, :sender_id, :integer, null: false, default: '' # メッセージ送信者のid
    add_column :messages, :title, :string, null: false, default: '' # メッセージタイトル
  end
end
