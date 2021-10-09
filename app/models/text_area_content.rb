class TextAreaContent < ApplicationRecord
  belongs_to :text_area

  validates :text_area_value, presence: true
end
