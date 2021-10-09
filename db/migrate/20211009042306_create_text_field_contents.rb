class CreateTextFieldContents < ActiveRecord::Migration[5.2]
  def change
    create_table :text_field_contents do |t|
      t.string :text_field_value, null: false, default: ''
      t.references :text_field, foreign_key: true

      t.timestamps
    end
  end
end
