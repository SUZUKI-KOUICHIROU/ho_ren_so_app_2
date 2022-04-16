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
  has_many :report_statuses, dependent: :destroy
  has_many :delegations

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
      unless self.report_statuses.exists?(user_id: user.id, deadline: next_deadline, is_newest: true)
        self.report_statuses.create(user_id: user.id, deadline: next_deadline)
      end
    end
  end

  # 引数に指定したIDを除く、プロジェクトメンバーを取得
  def other_members(my_id)
    return self.users.where.not(id: my_id)
  end

  def join_new_member(user_id)
    self.report_statuses.create(user_id: user_id, deadline: self.project_next_report_date)
  end

  # リーダー権限譲渡アクション。引数に元リーダーと次リーダーのユーザーIDを指定。
  def delegate_leader(from_user_id, to_member_id)
    self.delegations.where(is_valid: true).update_all(is_valid: false) # "最新である"フラグをfalseに
    self.delegations.create(user_from: from_user_id, user_to: to_member_id)
  end
end
