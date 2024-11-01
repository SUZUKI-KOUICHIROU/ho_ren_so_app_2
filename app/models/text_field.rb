class TextField < ApplicationRecord
  belongs_to :question

  validates :label_name, presence: true, length: { maximum: 30 }
  validates :field_type, presence: true
end
