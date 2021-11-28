class RadioButtonContent < ApplicationRecord
  belongs_to :radio_button
  attr_accessor :answer

  validates :radio_button_value, presence: true
end
