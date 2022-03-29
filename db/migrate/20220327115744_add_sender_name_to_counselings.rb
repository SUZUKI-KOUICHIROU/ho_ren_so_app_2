class AddSenderNameToCounselings < ActiveRecord::Migration[5.2]
  def change
    add_column :counselings, :sender_name, :string
  end
end
