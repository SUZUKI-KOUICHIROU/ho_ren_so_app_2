class CreateSelectOptionStrings < ActiveRecord::Migration[5.2]
  def change
    create_table :select_option_strings do |t|
      t.string :option_string, null: false, default: '' # 選択肢(select用)
      t.references :select, foreign_key: true

      t.timestamps
    end
  end
end
