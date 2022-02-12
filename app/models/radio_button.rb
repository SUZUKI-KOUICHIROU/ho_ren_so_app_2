class RadioButton < ApplicationRecord
  belongs_to :question
  has_many :radio_button_option_strings, dependent: :destroy
  has_many :radio_button_contents, dependent: :destroy
  accepts_nested_attributes_for :radio_button_option_strings, allow_destroy: true

  validates :label_name, presence: true
  validates :field_type, presence: true
end
