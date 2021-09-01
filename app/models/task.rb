class Task < ApplicationRecord
  belongs_to :projegt
  has_many :reports, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :counselings, dependent: :destroy


  validates :task_name, presence: true, uniqueness: true
  validates :task_rep_id, presence: true
  validates :task_report_frequency, presence: true
  validates :task_next_report_date, presence: true
  validates :task_reported_flag, presence: true
end
