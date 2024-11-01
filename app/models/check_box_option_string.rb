class CheckBoxOptionString < ApplicationRecord
  belongs_to :check_box

  validates :option_string, presence: true, length: { maximum: 30 }
end
