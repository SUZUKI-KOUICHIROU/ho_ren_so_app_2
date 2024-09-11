class Answer < ApplicationRecord
  belongs_to :report
  belongs_to :question
  # validates :array_value, acceptance: true
end
