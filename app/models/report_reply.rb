class ReportReply < ApplicationRecord
  belongs_to :report

  validates :reply_content, presence: true
end
