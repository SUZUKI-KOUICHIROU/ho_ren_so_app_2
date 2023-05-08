class Report < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :report_confirmers, dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true
  attribute :remanded, default: false
  attribute :resubmitted, default: false

  # validates :report_detail, presence: true
  validates :title, presence: true, length: { maximum: 30 }
  validates :report_day, presence: true
  validates :sender_name, presence: true
end
