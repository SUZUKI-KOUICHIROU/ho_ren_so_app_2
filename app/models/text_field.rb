class TextField < ApplicationRecord
  belongs_to :form_display_order
  has_many :text_field_contents, dependent: :destroy

  validates :label_name, presence: true
  validates :field_type, presence: true
end