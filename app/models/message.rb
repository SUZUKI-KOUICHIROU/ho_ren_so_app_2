class Message < ApplicationRecord
  belongs_to :project
  has_many :message_confirmers, dependent: :destroy

  attr_accessor :send_to

  attribute :send_to_all # , default: false

  validates :message_detail, presence: true
  validate :no_check_become_invalid

  # ログインユーザー宛のメッセージを取得
  def self.my_messages(user)
    joins(:message_confirmers).where(message_confirmers: { message_confirmer_id: user, message_confirmation_flag: false }).order(created_at: :desc)
  end

  # ログインユーザー宛メッセージ最新の５件を取得
  def self.my_recent_messages(user_id)
    joins(:message_confirmers).where(message_confirmers: { message_confirmer_id: user_id }).order(created_at: :desc).limit(5)
  end

  def checked_members
    buf = message_confirmers.where(message_confirmation_flag: true).select('message_confirmer_id')
    User.where(id: buf)
  end

  # 送信相手にTO ALLを選択していない場合
  # 送信相手を一名以上選択しているか。
  def no_check_become_invalid
    unless send_to_all
      if send_to.nil?
        errors.add "", "送信相手を選択してください。"
      end
    end
  end

  scope :search, ->(search_params) do
    return all if search_params.blank?

    messages = all

    if search_params[:created_at].present?
      messages = messages.created_at(search_params[:created_at])
    end

    if search_params[:keywords].present?
      messages = messages.keywords_like(search_params[:keywords])
    end

    messages
  end

  scope :created_at, ->(created_at) { where('created_at BETWEEN ? AND ?', "#{created_at} 00:00:00", "#{created_at} 23:59:59") }
  scope :keywords_like, ->(keywords) {
                          where('title LIKE ? OR sender_name LIKE ? OR message_detail LIKE ?', "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
                        }
end
