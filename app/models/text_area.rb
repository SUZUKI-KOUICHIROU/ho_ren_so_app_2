class TextArea < ApplicationRecord
  belongs_to :question

  validates :label_name, presence: true
  validates :field_type, presence: true
end
