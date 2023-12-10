class MessageReply < ApplicationRecord
  belongs_to :message
  has_many_attached :images, dependent: :destroy

  validates :reply_content, presence: true
end
