class Report < ApplicationRecord
  belongs_to :project
  has_many :check_box_contents
  has_many :text_field_contents
  has_many :text_area_contents
  has_many :radio_button_contents
  has_many :select_contents
  has_many :date_field_contents
  has_many :answers
  has_many :report_confirmers, dependent: :destroy

  # validates :report_detail, presence: true
end
