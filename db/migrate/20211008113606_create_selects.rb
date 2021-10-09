class CreateSelects < ActiveRecord::Migration[5.2]
  def change
    create_table :selects do |t|
      t.string :label_name, null: false, default: ''
      t.string :field_type, null: false, default: 'select'
      t.references :form_display_order, foreign_key: true

      t.timestamps
    end
  end
end
