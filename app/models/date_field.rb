class DateField < ApplicationRecord
  belongs_to :question
  has_many :date_field_contents, dependent: :destroy

  validates :label_name, presence: true
  validates :field_type, presence: true
end
