class AddImportanceToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :importance, :string
  end
end
