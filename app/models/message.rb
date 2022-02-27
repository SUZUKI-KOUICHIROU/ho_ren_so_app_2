class Message < ApplicationRecord
  belongs_to :project
  has_many :message_confirmers, dependent: :destroy
  attr_accessor :send_to

  validates :message_detail, presence: true
  # validates_presence_of(:send_to)
  # validates :send_to, a
  # validate :send_to, :no_check_become_invalid

  # ログインユーザー宛のメッセージを取得
  def self.my_messages(user)
    joins(:message_confirmers).where(message_confirmers: { message_confirmer_id: user, message_confirmation_flag: false }).order(created_at: :desc)
  end

  # ログインユーザー宛メッセージ最新の５件を取得
  def self.my_recent_messages(user_id)
    joins(:message_confirmers).where(message_confirmers: { message_confirmer_id: user_id }).order(created_at: :desc).limit(5)
  end

  def checkers
    buf = message_confirmers.where(message_confirmation_flag: true).select('message_confirmer_id')
    User.where(id: buf)
  end

  # def no_check_become_invalid
  #   if self.send_to.nil?
  #     errors.add "", "送信相手を選択してください。"
  #     redirect_to :new
  #   end
  # end
end
