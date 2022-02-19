class TextArea < ApplicationRecord
  belongs_to :question
  has_many :text_area_contents, dependent: :destroy

  validates :label_name, presence: true
  validates :field_type, presence: true
end
