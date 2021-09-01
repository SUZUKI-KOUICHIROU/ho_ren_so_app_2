class ReportConfirmer < ApplicationRecord
  belongs_to :report

  validates :report_confirmer_id, presence: true
  validates :report_confirmation_flag, presence: true
end
