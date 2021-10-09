class FormDisplayOrder < ApplicationRecord
  belongs_to :project
  has_one :text_field, dependent: :destroy
  has_one :text_area, dependent: :destroy
  has_one :check_box, dependent: :destroy
  has_one :radio_button, dependent: :destroy
  has_one :select, dependent: :destroy
end
