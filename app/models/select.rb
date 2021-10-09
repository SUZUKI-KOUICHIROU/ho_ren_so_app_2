class Select < ApplicationRecord
  belongs_to :form_display_order
  has_many :select_option_strings, dependent: :destroy
  has_many :select_contents, dependent: :destroy

  validates :label_name, presence: true
  validates :field_type, presence: true
end
