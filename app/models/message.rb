class Message < ApplicationRecord
  belongs_to :project
  attr_accessor :send_to
  # belongs_to :task
  has_many :message_confirmers, dependent: :destroy

  validates :message_detail, presence: true
 
    # ログインユーザー宛のメッセージを取得
    def self.my_messages(user) 
      return self.joins(:message_confirmers).where(message_confirmers: { message_confirmer_id: user}).order(created_at: :desc)
    end

    # ログインユーザー宛メッセージ最新の５件を取得
    def self.my_recent_messages(user_id) 
      return self.joins(:message_confirmers).where(message_confirmers: { message_confirmer_id: user_id}).order(created_at: :desc).limit(5)
    end

    def checkers
      buf = self.message_confirmers.where(message_confirmation_flag: true).select("message_confirmer_id")
      return User.where(id: buf)
    end
end