class TextFieldContent < ApplicationRecord
  belongs_to :text_field
  attr_accessor :answer

  validates :text_field_value, presence: true
end
