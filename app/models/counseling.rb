class Counseling < ApplicationRecord
  belongs_to :project
  attr_accessor :send_to

  # belongs_to :task
  has_many :counseling_confirmers, dependent: :destroy

  validates :counseling_detail, presence: true
  # validates :counseling_reply_flag, inclusion: [true, false]

  # ログインユーザー宛のメッセージを取得
  def self.my_counselings(user)
    joins(:counseling_confirmers).where(counseling_confirmers: { counseling_confirmer_id: user }).order(created_at: :desc)
  end

  # ログインユーザー宛メッセージ最新の５件を取得
  def self.my_recent_counselings(user)
    joins(:counseling_confirmers).where(counseling_confirmers: { counseling_confirmer_id: user }).order(created_at: :desc).limit(5)
  end

  # 確認者を抽出
  def checkers
    buf = counseling_confirmers.where(counseling_confirmation_flag: true).select('counseling_confirmer_id')
    User.where(id: buf)
  end
end
