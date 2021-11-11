class CreateCheckBoxOptionStrings < ActiveRecord::Migration[5.2]
  def change
    create_table :check_box_option_strings do |t|
      t.string :option_string, null: false, default: '' # 選択肢(check_box用)
      t.references :check_box, foreign_key: true

      t.timestamps
    end
  end
end
