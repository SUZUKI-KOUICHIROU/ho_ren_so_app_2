class CreateAnswer < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.string :question_type
      t.integer :question_id #設問レコードID
      t.string :value #回答内容
      t.text :array_value, array: true #チェックボックス回答
      t.references :report, foreign_key: true
    end
  end
end
