class Answer < ApplicationRecord
  belongs_to :report
  serialize :array_value, Array

  validates :array_value, acceptance: true
end
