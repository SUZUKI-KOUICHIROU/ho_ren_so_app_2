class Counseling < ApplicationRecord
  belongs_to :project
  has_many :counseling_confirmers, dependent: :destroy
  has_many :counseling_replies, dependent: :destroy
  has_many_attached :images, dependent: :destroy

  attr_accessor :send_to

  attribute :send_to_all

  validates :counseling_detail, presence: true
  # validates :counseling_reply_flag, inclusion: [true, false]
  validate :no_check_become_invalid

  # ログインユーザー宛のメッセージを取得
  def self.my_counselings(user)
    joins(:counseling_confirmers).where(counseling_confirmers:
      { counseling_confirmer_id: user, counseling_confirmation_flag: false }).order(created_at: :desc)
  end

  # ログインユーザー宛メッセージ最新の５件を取得
  def self.my_recent_counselings(user)
    joins(:counseling_confirmers).where(counseling_confirmers: { counseling_confirmer_id: user }).order(created_at: :desc).limit(5)
  end

  # 確認者を抽出
  def checked_members
    buf = counseling_confirmers.where(counseling_confirmation_flag: true).select('counseling_confirmer_id')
    User.where(id: buf)
  end

  # 送信相手を一名以上選択しているか。
  def no_check_become_invalid
    unless send_to_all
      if send_to.nil?
        errors.add "", "送信相手を選択してください。"
      end
    end
  end

  # 検索機能
  def self.search(search_params)
    query = all
    if search_params[:keywords].present?
      keyword = "%#{search_params[:keywords]}%"
      query = query.where("title LIKE :keyword OR counseling_detail LIKE :keyword", keyword: keyword)
    end
    query
  end
end
