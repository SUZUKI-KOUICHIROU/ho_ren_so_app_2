class Report < ApplicationRecord
  belongs_to :project
  belongs_to :task
  has_many :reportconfirmers, dependent: :destroy

  validates :report_detail, presence: true
end
