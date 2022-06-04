class AddColumnToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :required, :boolean, null: false, default: false
  end
end
