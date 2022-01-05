class CreateDateFields < ActiveRecord::Migration[5.2]
  def change
    create_table :date_fields do |t|
      t.string :label_name, null: false, default: '' # ラベル名
      t.string :field_type, null: false, default: 'date_field' # 入力フィールドのタイプ
      t.references :form_display_order, foreign_key: true

      t.timestamps
    end
  end
end
