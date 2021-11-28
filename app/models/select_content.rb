class SelectContent < ApplicationRecord
  belongs_to :select
  attr_accessor :answer

  validates :select_value, presence: true
end
