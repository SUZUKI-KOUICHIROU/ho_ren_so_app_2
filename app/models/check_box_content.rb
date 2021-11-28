class CheckBoxContent < ApplicationRecord
  belongs_to :check_box
  attr_accessor :answer

  validates :check_box_value, presence: true
end
