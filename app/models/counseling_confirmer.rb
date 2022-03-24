class CounselingConfirmer < ApplicationRecord
  belongs_to :counseling

  validates :counseling_confirmer_id, presence: true
  validates :counseling_confirmation_flag, inclusion: [true, false]

  # 確認した/しないを切り替える　そのうちメソッド名を変更したい
  def switch_read_flag
    self.update(counseling_confirmation_flag: !counseling_confirmation_flag)
  end
end
