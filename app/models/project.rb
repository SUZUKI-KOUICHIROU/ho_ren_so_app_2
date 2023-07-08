class Project < ApplicationRecord
  attr_accessor :report_frequency_selection, :week_select

  has_one  :format, dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  has_many :reports, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :counselings, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :joins
  has_many :tokens, through: :joins
  has_many :report_statuses, dependent: :destroy
  has_many :delegations, dependent: :destroy
  has_many :report_deadlines, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :description, presence: true, length: { maximum: 200 }
  validates :leader_id, presence: true
  validates :report_frequency, presence: true
  validates :next_report_date, presence: true
  validates :reported_flag, inclusion: [true, false]

  # 報告の期限を更新。引数には新しい報告日を指定
  def update_deadline(next_deadline)
    if next_deadline < Date.today # 引数が過去日付の場合、処理を終了
      puts "本日以前の日付は指定できません"
      exit
    end

    self.report_statuses.where(is_newest: true).update_all(is_newest: false) # "最新である"フラグをfalseに
    self.users.all.find_each do |user|
      unless self.report_statuses.exists?(user_id: user.id, deadline: next_deadline, is_newest: true)
        self.report_statuses.create(user_id: user.id, deadline: next_deadline)
      end
    end
  end

  # 日数か曜日によって次回報告日を更新する
  def update_next_report_date(report_frequency_selection, week_select)
    if report_frequency_selection == "edit_day" || report_frequency_selection == "day"
      # 一日に一回の次回報告日は今日であるため、昨日をベースにする
      next_report_date_calc = Date.yesterday + self.report_frequency
      self.update(next_report_date: next_report_date_calc) unless self.next_report_date == next_report_date_calc
    else
      next_report_date_week_update(week_select)
    end
  end

  def next_report_date_week_update(week_select)
    next_report_week = Date.today.next_occurring(week_selecter[week_select])
    self.update(next_report_date: next_report_week) unless self.next_report_date == next_report_week
  end

  def week_selecter
    return {
      "日" => :sunday,
      "月" => :monday,
      "火" => :tuesday,
      "水" => :wednesday,
      "木" => :thursday,
      "金" => :friday,
      "土" => :saturday
    }
  end

  # デフォルト報告フォーマット作成アクション(projects/projects#create内で呼ばれる)
  def report_format_creation
    text_area = TextArea.new(label_name: '報告内容')
    text_area.build_question(
      position: 2,
      form_table_type: text_area.field_type,
      project_id: self.id
    )
    text_area.save

    radio_button = RadioButton.new(label_name: '発生している問題')
    radio_button.build_question(
      position: 3,
      form_table_type: radio_button.field_type,
      project_id: self.id
    )
    radio_button.save
    radio_button.radio_button_option_strings.create!(option_string: 'あり')
    radio_button.radio_button_option_strings.create!(option_string: 'なし')

    text_area = TextArea.new(label_name: '問題内容')
    text_area.build_question(
      position: 4,
      form_table_type: text_area.field_type,
      project_id: self.id
    )
    text_area.save
  end

  # 引数に指定したIDを除く、プロジェクトメンバーを取得
  def other_members(my_id)
    return self.users.where.not(id: my_id)
  end

  def join_new_member(user_id)
    self.report_statuses.create(user_id: user_id, deadline: self.next_report_date)
  end

  # リーダー権限譲渡アクション。引数に元リーダーと次リーダーのユーザーIDを指定。
  def delegate_leader(from_user_id, to_member_id)
    self.delegations.where(is_valid: true).update_all(is_valid: false) # "最新である"フラグをfalseに
    self.delegations.create(user_from: from_user_id, user_to: to_member_id)
  end
end
