class Answer < ApplicationRecord
  belongs_to :report

  # validates :array_value, acceptance: true
end
