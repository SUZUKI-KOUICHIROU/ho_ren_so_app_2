class AddNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user_name, :string, null: false, default: '' # ユーザー名
    add_column :users, :admin, :boolean, null: false, default: false # 管理者フラグ
  end
end
