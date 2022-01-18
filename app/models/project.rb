class Project < ApplicationRecord
  attr_accessor :report_frequency_selection, :week_select

  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  # has_many :tasks, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :counselings, dependent: :destroy
  has_many :form_display_orders, dependent: :destroy
  has_many :joins
  has_many :tokens, through: :joins

  validates :project_name, presence: true, length: { maximum: 20 }
  validates :project_leader_id, presence: true
  validates :project_report_frequency, presence: true
  validates :project_next_report_date, presence: true
  validates :project_reported_flag, inclusion: [true, false]
end
