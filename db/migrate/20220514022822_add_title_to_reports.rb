class AddTitleToReports < ActiveRecord::Migration[5.2]
  def up
    add_column :reports, :title, :string, null:false
  end
end
