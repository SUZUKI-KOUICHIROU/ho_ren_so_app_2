class CreateRadioButtons < ActiveRecord::Migration[5.2]
  def change
    create_table :radio_buttons do |t|
      t.string :label_name, null: false, default: '' # ラベル名
      t.string :field_type, null: false, default: 'radio_button' # 入力フィールドのタイプ
      t.string :option_string, null: false, default: '' # ラジオボタンの文字列
      t.references :form_display_order, foreign_key: true

      t.timestamps
    end
  end
end
