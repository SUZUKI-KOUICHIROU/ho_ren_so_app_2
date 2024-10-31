class CheckBox < ApplicationRecord
  belongs_to :question
  has_many :check_box_option_strings, dependent: :destroy
  accepts_nested_attributes_for :check_box_option_strings, allow_destroy: true

  validates :label_name, presence: true, length: { maximum: 30 }
  validates :field_type, presence: true
end