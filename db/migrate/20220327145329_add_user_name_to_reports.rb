class AddUserNameToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :sender_id, :integer
    add_column :reports, :sender_name, :string
  end
end
