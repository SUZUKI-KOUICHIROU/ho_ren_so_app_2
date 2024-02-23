class ReportReply < ApplicationRecord
  belongs_to :report
  has_many_attached :images, dependent: :destroy

  validates :reply_content, presence: true, length: { maximum: 500 }
end
