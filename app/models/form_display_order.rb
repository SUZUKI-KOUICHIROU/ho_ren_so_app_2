class FormDisplayOrder < ApplicationRecord
  belongs_to :project
  has_one :text_field, dependent: :destroy
  has_one :text_area, dependent: :destroy
  has_one :check_box, dependent: :destroy
  has_one :radio_button, dependent: :destroy
  has_one :select, dependent: :destroy
  accepts_nested_attributes_for :text_field, allow_destroy: true
  accepts_nested_attributes_for :text_area, allow_destroy: true
  accepts_nested_attributes_for :check_box, allow_destroy: true
  accepts_nested_attributes_for :radio_button, allow_destroy: true
  accepts_nested_attributes_for :select, allow_destroy: true

  validates :position, presence: true, uniqueness: { scope: :project_id }
end
