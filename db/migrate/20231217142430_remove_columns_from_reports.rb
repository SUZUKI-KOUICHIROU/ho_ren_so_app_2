class RemoveColumnsFromReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :reports, :remanded, :boolean
    remove_column :reports, :remanded_reason, :string
    remove_column :reports, :resubmitted, :boolean
  end
end
