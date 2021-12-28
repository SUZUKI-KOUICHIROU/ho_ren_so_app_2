class CreateDateFieldContents < ActiveRecord::Migration[5.2]
  def change
    create_table :date_field_contents do |t|
      t.date :date_field_value, null: false, default: '' # 入力内容(date_field用)
      t.references :date_field, foreign_key: true

      t.timestamps
    end
  end
end
