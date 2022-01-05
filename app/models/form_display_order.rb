class FormDisplayOrder < ApplicationRecord
  belongs_to :project
  has_one :text_field, dependent: :destroy
  has_one :text_area, dependent: :destroy
  has_one :check_box, dependent: :destroy
  has_one :radio_button, dependent: :destroy
  has_one :select, dependent: :destroy
  has_one :date_field, dependent: :destroy
  accepts_nested_attributes_for :text_field, allow_destroy: true
  accepts_nested_attributes_for :text_area, allow_destroy: true
  accepts_nested_attributes_for :check_box, allow_destroy: true
  accepts_nested_attributes_for :radio_button, allow_destroy: true
  accepts_nested_attributes_for :select, allow_destroy: true
  accepts_nested_attributes_for :date_field, allow_destroy: true

  validates :position, presence: true
  validates :position, presence: true
  validates :form_table_type, presence: true
  validates :using_flag, inclusion: [true, false]
end
