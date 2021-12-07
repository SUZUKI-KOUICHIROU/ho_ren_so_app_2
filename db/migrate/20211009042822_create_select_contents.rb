class CreateSelectContents < ActiveRecord::Migration[5.2]
  def change
    create_table :select_contents do |t|
      t.string :select_value, null: false, default: '' # 選択された値(select用)
      t.references :select, foreign_key: true
      t.references :report, foreign_key: true
      
      t.timestamps
    end
  end
end
