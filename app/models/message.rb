class Message < ApplicationRecord
  belongs_to :project
  has_many :message_confirmers, dependent: :destroy
  has_many :message_replies, dependent: :destroy
  has_many_attached :images, dependent: :destroy

  attr_accessor :send_to

  attribute :send_to_all # , default: false

  validates :title, presence: true, length: { maximum: 30 }
  validates :message_detail, presence: true, length: { maximum: 500 }
  validate :no_check_become_invalid

  def set_importance(importance, recipients)
    self.importance = importance
    if importance == '中' || importance == '高'
      recipients.each do |_recipient|
        MessageMailer.send_email(recipients, self.importance, self.title, self.message_detail, self.sender_name).deliver_now
      end
    end
    if importance == '高'
      send_slack_notification(self.title, self.message_detail)
    end
  end

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

  # 月次連絡を取得する
  def self.monthly_messages_for(project)
    start_of_month = Time.zone.now.beginning_of_month
    end_of_month = Time.zone.now.end_of_month
    Message.where(project: project, created_at: start_of_month..end_of_month)
  end

  # 連絡の日付とキーワードの検索
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

  scope :created_at, ->(created_at) {
    where("created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Tokyo' BETWEEN ? AND ?", "#{created_at} 00:00:00", "#{created_at} 23:59:59")
  }
  scope :keywords_like, ->(keywords) {
    where('title LIKE ? OR sender_name LIKE ? OR message_detail LIKE ?', "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
  }

  private

  def send_slack_notification(title, message_detail)
    client = Slack::Web::Client.new
    # channel = "#Horenso_App" # 参照資料には記述されていたがrubocopで不要と警告が出た為コメントアウトとする。
    message = "重要度「高」の連絡が届いています。 \n送信者: #{self.sender_name}\n件名: #{title}\n連絡内容: #{message_detail}"
    client.chat_postMessage(channel: '#horenso_app通知', text: message)
  end
end
