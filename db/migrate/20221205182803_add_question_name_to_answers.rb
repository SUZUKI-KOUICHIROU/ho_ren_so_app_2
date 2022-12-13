class AddQuestionNameToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :question_name, :string
  end
end
