class TextAreaContent < ApplicationRecord
  belongs_to :text_area
  attr_accessor :answer

  validates :text_area_value, presence: true
end
