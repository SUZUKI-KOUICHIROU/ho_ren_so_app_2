class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token, :invite_token
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
  
  #ユーザー招待の属性（トークンとダイジェストと、招待したユーザーのid）を作成する。
  def create_invite_digest
    self.invite_token = User.new_token
    update_attributes(invite_sent_at: Time.zone.now)
  end
  
  #招待メールを送信する
  def send_invite_email
    UserMailer.invitation(self).deliver_now
  end

  #招待の期限が切れている場合はtrueを返す
  def invitation_expired?
    self.invite_sent_at < 24.hours.ago
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  before_save { self.email = email.downcase }

  validates :user_name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true

  VALID_PASSWORD_REGEX = /\A[a-z0-9]+\z/.freeze
  validates :password, presence: true, length: { maximum: 50, minimum: 6 },
            format: { with: VALID_PASSWORD_REGEX,
            message: 'は半角英数（英字は小文字のみ）で入力して下さい' },
            allow_blank: true
  validates :password_confirmation, presence: true, length: { maximum: 50, minimum: 6 },
                                    format: { with: VALID_PASSWORD_REGEX,
                                              message: 'は半角英数（英字は小文字のみ）で入力して下さい' },
                                    allow_blank: true

end
