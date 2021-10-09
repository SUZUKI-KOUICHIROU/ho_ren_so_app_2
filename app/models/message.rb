class Message < ApplicationRecord
  belongs_to :project
  belongs_to :task
  has_many :message_confirmers, dependent: :destroy

  validates :message_detail, presence: true
end
