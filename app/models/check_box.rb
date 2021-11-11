class CheckBox < ApplicationRecord
  belongs_to :form_display_order
  has_many :check_box_option_strings, dependent: :destroy
  has_many :check_box_contents, dependent: :destroy
  accepts_nested_attributes_for :check_box_option_strings, allow_destroy: true

  validates :label_name, presence: true
  validates :field_type, presence: true
end
