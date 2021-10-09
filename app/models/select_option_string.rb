class SelectOptionString < ApplicationRecord
  belongs_to :select

  validates :option_string, presence: true
end
