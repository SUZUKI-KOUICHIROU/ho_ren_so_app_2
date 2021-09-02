class Counseling < ApplicationRecord
  belongs_to :projegt
  belongs_to :task
  has_many :counselingconfirmers, dependent: :destroy

  validates :counseling_detail, presence: true
  validates :counseling_reply_flag, presence: true
end
