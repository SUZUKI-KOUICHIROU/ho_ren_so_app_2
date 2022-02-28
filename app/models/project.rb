class Project < ApplicationRecord
  attr_accessor :report_frequency_selection, :week_select

  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  has_many :reports, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :counselings, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :joins
  has_many :tokens, through: :joins
  has_many :report_statuses
  
  validates :project_name, presence: true, length: { maximum: 20 }
  validates :project_leader_id, presence: true
  validates :project_report_frequency, presence: true
  validates :project_next_report_date, presence: true
  validates :project_reported_flag, inclusion: [true, false]

  # 報告の期限を更新。引数には新しい報告日を指定
  def update_deadline(next_deadline)
    if next_deadline < Date.today # 引数が過去日付の場合、処理を終了
      puts "本日以前の日付は指定できません"
      exit
    end

    self.report_statuses.where(is_newest: true).update_all(is_newest: false) # "最新である"フラグをfalseに
    self.users.all.each do |user|
      unless self.report_statuses.exists?(user_id: user.id, deadline: next_deadline)
        self.report_statuses.create(user_id: user.id, deadline: next_deadline)
      end
    end
  end

  # 引数に指定したIDを除く、プロジェクトメンバーを取得
  def other_members(my_id)
    return self.users.where.not(id: my_id)
  end

  def join_new_member(user)
    self.report_statuses.create(user_id: user.id, deadline: next_deadline)
  end
end
