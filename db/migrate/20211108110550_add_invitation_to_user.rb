class AddInvitationToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :invite_digest, :string
    add_column :users, :invited_by, :integer
    add_column :users, :invite_sent_at, :datetime
  end
end
