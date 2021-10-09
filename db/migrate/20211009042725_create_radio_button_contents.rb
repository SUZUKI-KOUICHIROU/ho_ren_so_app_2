class CreateRadioButtonContents < ActiveRecord::Migration[5.2]
  def change
    create_table :radio_button_contents do |t|
      t.string :radio_button_value, null: false, default: ''
      t.references :radio_button, foreign_key: true

      t.timestamps
    end
  end
end
