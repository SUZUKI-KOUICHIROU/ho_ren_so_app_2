class CreateCheckBoxes < ActiveRecord::Migration[5.2]
  def change
    create_table :check_boxes do |t|
      t.string :label_name, null: false, default: ''
      t.string :field_type, null: false, default: 'check_box'
      t.string :option_string, null: false, default: ''
      t.references :form_display_order, foreign_key: true

      t.timestamps
    end
  end
end
