class CreateDelegations < ActiveRecord::Migration[5.2]
  # リーダー権限を委譲する時用のテーブル
  def change
    create_table :delegations do |t|
      t.references :project, foreign_key: true
      t.integer :user_from, foreign_key: true # 誰から
      t.integer :user_to # 誰に対して
      t.boolean :is_valid, default: true # 最新のものか
      t.timestamps
    end
  end
end
