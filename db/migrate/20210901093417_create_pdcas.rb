class CreatePdcas < ActiveRecord::Migration[5.2]
  def change
    create_table :pdcas do |t|
      t.text :pdca_plan, null: false, default: '' # 計画
      t.text :pdca_do, null: false, default: '' # 行動
      t.text :pdca_check, null: false, default: '' # 評価
      t.text :pdca_action, null: false, default: '' # 改善

      t.timestamps
    end
  end
end
