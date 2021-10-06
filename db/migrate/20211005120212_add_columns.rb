class AddColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :description, :string
    add_column :messages, :sender_id, :integer
    add_column :messages, :title, :string
  end
end
