class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.integer :position # 表示順を管理するgemで必要
      t.string :form_table_type, null: false, default: '' # アソシエーション名
      t.references :project, foreign_key: true
      t.boolean :using_flag, null: false, default: true # 使用フラグ

      t.timestamps
    end
  end
end
