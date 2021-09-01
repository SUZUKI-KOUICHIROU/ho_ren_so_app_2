class Pdca < ApplicationRecord
  validates :pdca_plan, presence: true
  validates :pdca_do, presence: true
  validates :pdca_check, presence: true
  validates :pdca_action, presence: true
end
