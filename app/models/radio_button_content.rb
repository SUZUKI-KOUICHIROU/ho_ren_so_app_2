class RadioButtonContent < ApplicationRecord
  belongs_to :radio_button

  validates :radio_button_value, presence: true
end
