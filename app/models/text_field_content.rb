class TextFieldContent < ApplicationRecord
  belongs_to :text_field

  validates :text_field_value, presence: true
end
