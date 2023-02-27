class AddRemandsToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :resubmitted, :boolean, defalut: false
  end
end
