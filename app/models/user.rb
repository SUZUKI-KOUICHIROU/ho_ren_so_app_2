class User < ApplicationRecord
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
<<<<<<< HEAD
end
=======

  has_many :projects, through: :project_users
  has_many :project_users, dependent: :destroy

  before_save { self.email = email.downcase }

  validates :user_name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true

  VALID_PASSWORD_REGEX = /\A[a-z0-9]+\z/
  validates :password, presence: true, length: { maximum: 50, minimum: 6 },
            format: { with: VALID_PASSWORD_REGEX,
            message: "は半角英数（英字は小文字のみ）で入力して下さい"},
            allow_blank: true
  validates :password_confirmation, presence: true, length: { maximum: 50, minimum: 6 },
            format: { with: VALID_PASSWORD_REGEX,
            message: "は半角英数（英字は小文字のみ）で入力して下さい"},
            allow_blank: true
  #validates :admin, presence: true, length: { maximum: 50 }
  #validates :leader, presence: true, length: { maximum: 50 }

end
>>>>>>> 8d7b6c3ffba21fe75149bc288758527089441853
