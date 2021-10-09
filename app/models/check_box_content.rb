class CheckBoxContent < ApplicationRecord
  belongs_to :check_box

  validates :check_box_value, presence: true
end
