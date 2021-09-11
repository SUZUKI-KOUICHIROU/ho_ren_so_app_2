class Project < ApplicationRecord
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  has_many :tasks, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :counselings, dependent: :destroy

  validates :project_name, presence: true, uniqueness: true
  validates :project_leader_id, presence: true
  validates :project_report_frequency, presence: true
  validates :project_next_report_date, presence: true
  validates :project_reported_lag, presence: true
end
