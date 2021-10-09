class CreateFormDisplayOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :form_display_orders do |t|
      t.integer :position
      t.string :form_table_type, null: false, default: ''
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
