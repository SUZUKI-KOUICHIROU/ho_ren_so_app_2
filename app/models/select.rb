class Select < ApplicationRecord
  belongs_to :question
  has_many :select_option_strings, dependent: :destroy
  accepts_nested_attributes_for :select_option_strings, allow_destroy: true

  validates :label_name, presence: true, length: { maximum: 30 }
  validates :field_type, presence: true
end
