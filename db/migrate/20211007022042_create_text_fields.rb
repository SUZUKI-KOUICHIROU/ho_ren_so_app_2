class CreateTextFields < ActiveRecord::Migration[5.2]
  def change
    create_table :text_fields do |t|
      t.string :label_name, null: false, default: '' # ラベル名
      t.string :field_type, null: false, default: 'text_field' # 入力フィールドのタイプ
      t.references :questions, foreign_key: true

      t.timestamps
    end
  end
end
