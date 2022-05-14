class CreateFormats < ActiveRecord::Migration[5.2]
  def change
    create_table :formats do |t|
      t.string :title, null: false
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
