class CreateTextAreaContents < ActiveRecord::Migration[5.2]
  def change
    create_table :text_area_contents do |t|
      t.string :text_area_value, null: false, default: ''
      t.references :text_area, foreign_key: true

      t.timestamps
    end
  end
end
