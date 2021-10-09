class SelectContent < ApplicationRecord
  belongs_to :select

  validates :select_value, presence: true
end
