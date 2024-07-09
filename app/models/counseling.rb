class Counseling < ApplicationRecord
  belongs_to :project
  has_many :counseling_confirmers, dependent: :destroy
  has_many :counseling_replies, dependent: :destroy
  has_many_attached :images, dependent: :destroy

  attr_accessor :send_to

  attribute :send_to_all

  validates :counseling_detail, presence: true
  validate :no_check_become_invalid

  scope :created_at, ->(created_at) {
    where("created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Tokyo' BETWEEN ? AND ?", "#{created_at} 00:00:00", "#{created_at} 23:59:59")
  }
  
  scope :keywords_like, ->(keywords) {
    where('title LIKE ? OR sender_name LIKE ? OR counseling_detail LIKE ?', "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
  }

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

  # 月次連絡を取得する
  def self.monthly_counselings_for(project)
    start_of_month = Time.zone.now.beginning_of_month
    end_of_month = Time.zone.now.end_of_month
    where(project: project, created_at: start_of_month..end_of_month)
  end
end
