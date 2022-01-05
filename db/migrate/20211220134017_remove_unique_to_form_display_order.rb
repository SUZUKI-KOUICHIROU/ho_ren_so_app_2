class RemoveUniqueToFormDisplayOrder < ActiveRecord::Migration[5.2]
  def change
      remove_index :form_display_orders, column: [:position, :project_id]
      add_index    :form_display_orders, :position
  end
end
