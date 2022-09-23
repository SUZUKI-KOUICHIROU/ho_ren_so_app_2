class ReportDeadline < ApplicationRecord
  belongs_to :project

  validates :day, presence: true
end
