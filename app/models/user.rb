class User < ApplicationRecord
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  has_many :report_statuses, dependent: :destroy

  has_many :reports, dependent: :nullify
  attr_accessor :remember_token, :activation_token, :reset_token, :invite_token, :member_expulsion

  # 招待メールを送信する
  def send_invite_email(token, name, password)
    UserMailer.invitation(self, token, name, password).deliver_now
  end

  # 現在のパスワードなしでユーザー情報を変更
  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end

  def project_leader?
    return Project.exists?(leader_id: self.id)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :trackable, :rememberable, :validatable

  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 20 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 100 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: true

  # VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)(?=.*?[\W_])[!-~]{6,}+\z/.freeze 'パスワードに小大英字記号を含ませる正規表現'
  VALID_PASSWORD_REGEX = /\A[a-z0-9]+\z/.freeze # 半角英数
  MESSAGE_WITH_INVALID_PASSWORD = 'は半角英数（英字は小文字のみ）で入力して下さい'
  validates :password,
    allow_blank: true,
    presence: true,
    length: { maximum: 30, minimum: 8 },
    format: { with: VALID_PASSWORD_REGEX,
              message: MESSAGE_WITH_INVALID_PASSWORD }

  validates :password_confirmation,
    allow_blank: true,
    presence: true,
    length: { maximum: 30, minimum: 8 },
    format: { with: VALID_PASSWORD_REGEX,
              message: MESSAGE_WITH_INVALID_PASSWORD }
end
