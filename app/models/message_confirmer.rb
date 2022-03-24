class MessageConfirmer < ApplicationRecord
  belongs_to :message

  validates :message_confirmer_id, presence: true
  validates :message_confirmation_flag, inclusion: [true, false]

  # 確認した/しないを切り替える　そのうちメソッド名を変更したい
  def switch_read_flag
    self.update(message_confirmation_flag: !message_confirmation_flag)
  end
end
