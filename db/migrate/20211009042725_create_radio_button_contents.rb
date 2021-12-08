class CreateRadioButtonContents < ActiveRecord::Migration[5.2]
  def change
    create_table :radio_button_contents do |t|
      t.string :radio_button_value, null: false, default: '' # 選択された値(radio_button用)
      t.references :radio_button, foreign_key: true
      t.references :report, foreign_key: true
      
      t.timestamps
    end
  end
end
