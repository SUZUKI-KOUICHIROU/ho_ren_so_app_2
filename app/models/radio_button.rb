class RadioButton < ApplicationRecord
  belongs_to :form_display_order
  has_many :radio_button_contents, dependent: :destroy

  validates :label_name, presence: true
  validates :field_type, presence: true
  validates :option_string, presence: true
end
