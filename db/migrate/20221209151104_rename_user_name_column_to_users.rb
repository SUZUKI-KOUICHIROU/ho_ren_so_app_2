class RenameUserNameColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :user_name, :name
  end
end
