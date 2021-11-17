class CreateRadioButtonOptionStrings < ActiveRecord::Migration[5.2]
  def change
    create_table :radio_button_option_strings do |t|
      t.string :option_string, null: false, default: '' # 選択肢(radio_button用)
      t.references :radio_button, foreign_key: true

      t.timestamps
    end
  end
end
