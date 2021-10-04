class Message < ApplicationRecord
  belongs_to :project
  belongs_to :task
  has_many :messageconfirmers, dependent: :destroy

  validates :message_detail, presence: true
end
