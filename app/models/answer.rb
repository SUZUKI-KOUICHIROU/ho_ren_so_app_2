class Answer < ApplicationRecord
  belongs_to :report
  serialize :array_value, Array
end
