class Report < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :report_confirmers, dependent: :destroy

  # validates :report_detail, presence: true
end
