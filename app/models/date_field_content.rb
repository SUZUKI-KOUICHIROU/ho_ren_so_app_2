class DateFieldContent < ApplicationRecord
  belongs_to :date_field
  attr_accessor :answer

  validates :date_field_value, presence: true
end
