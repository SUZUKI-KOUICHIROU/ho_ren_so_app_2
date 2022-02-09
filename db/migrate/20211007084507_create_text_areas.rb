class CreateTextAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :text_areas do |t|
      t.string :label_name, null: false, default: '' # ラベル名
      t.string :field_type, null: false, default: 'text_area' # 入力フィールドのタイプ
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
