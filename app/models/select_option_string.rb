class SelectOptionString < ApplicationRecord
  belongs_to :select

  validates :option_string, presence: true, length: { maximum: 30 }
end
