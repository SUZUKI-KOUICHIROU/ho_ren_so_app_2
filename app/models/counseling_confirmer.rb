class CounselingConfirmer < ApplicationRecord
  belongs_to :counseling

  validates :counseling_confirmer_id, presence: true
  validates :counseling_confirmation_flag, inclusion: [true, false]

  def switch_read_flag
    self.counseling_confirmation_flag = self.counseling_confirmation_flag ? false : true
    self.save
  end

end