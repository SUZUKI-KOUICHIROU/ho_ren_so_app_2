class CounselingReply < ApplicationRecord
  belongs_to :counseling
  has_many_attached :images, dependent: :destroy

  validates :reply_content, presence: true
end
