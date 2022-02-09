class CreateSelects < ActiveRecord::Migration[5.2]
  def change
    create_table :selects do |t|
      t.string :label_name, null: false, default: '' # ラベル名
      t.string :field_type, null: false, default: 'select' # 入力フィールドのタイプ
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
