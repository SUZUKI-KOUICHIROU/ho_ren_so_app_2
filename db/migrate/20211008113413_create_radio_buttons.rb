class CreateRadioButtons < ActiveRecord::Migration[5.2]
  def change
    create_table :radio_buttons do |t|
      t.string :label_name, null: false, default: '' # ラベル名
      t.string :field_type, null: false, default: 'radio_button' # 入力フィールドのタイプ
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
