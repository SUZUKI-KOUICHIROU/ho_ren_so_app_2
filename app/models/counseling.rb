# app/models/counseling.rb

class Counseling < ApplicationRecord
  belongs_to :project
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'  # Assuming sender is a User and 'sender_id' is the foreign key

  has_many :counseling_confirmers, dependent: :destroy
  has_many :counseling_replies, dependent: :destroy
  has_many_attached :images, dependent: :destroy

  attr_accessor :send_to

  attribute :send_to_all, :boolean

  validates :counseling_detail, presence: true
  validate :validate_send_to_presence

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
    counseling_confirmers.where(counseling_confirmation_flag: true).map(&:user)
  end

  # 送信相手を一名以上選択しているかを確認するバリデーション
  def validate_send_to_presence
    if !send_to_all && send_to.blank?
      errors.add(:send_to, "送信相手を選択してください。")
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

  # 月次相談を取得する
  def self.monthly_counselings_for(project)
    start_of_month = Time.zone.now.beginning_of_month
    end_of_month = Time.zone.now.end_of_month
    where(project: project, created_at: start_of_month..end_of_month)
  end
end
