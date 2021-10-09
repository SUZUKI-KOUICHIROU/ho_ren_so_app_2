class CreateCheckBoxContents < ActiveRecord::Migration[5.2]
  def change
    create_table :check_box_contents do |t|
      t.string :check_box_value, null: false, default: ''
      t.references :check_box, foreign_key: true

      t.timestamps
    end
  end
end
