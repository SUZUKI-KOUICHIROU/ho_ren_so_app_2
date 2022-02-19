class Pdca < ApplicationRecord
  belongs_to :user

  validates :pdca_plan, presence: true
  validates :pdca_do, presence: true
  validates :pdca_check, presence: true
  validates :pdca_action, presence: true
end
