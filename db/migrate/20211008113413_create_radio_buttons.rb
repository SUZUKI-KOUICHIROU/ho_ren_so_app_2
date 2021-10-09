class CreateRadioButtons < ActiveRecord::Migration[5.2]
  def change
    create_table :radio_buttons do |t|
      t.string :label_name, null: false, default: ''
      t.string :field_type, null: false, default: 'radio_button'
      t.string :option_string, null: false, default: ''
      t.references :form_display_order, foreign_key: true

      t.timestamps
    end
  end
end
