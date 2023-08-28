class AddColumToProjectUser < ActiveRecord::Migration[5.2]
  def change
    add_column :project_users, :member_expulsion, :boolean, default: false, null: false
  end
end
