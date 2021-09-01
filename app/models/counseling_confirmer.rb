class CounselingConfirmer < ApplicationRecord
  belongs_to :counseling

  validates :counseling_confirmer_id, presence: true
  validates :counseling_confirmation_flag, presence: true
end
