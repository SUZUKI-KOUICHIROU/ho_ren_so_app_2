class MessageConfirmer < ApplicationRecord
  belongs_to :message

  validates :message_confirmer_id, presence: true
  validates :message_confirmation_flag, inclusion: [true, false]

  def switch_read_flag
    self.message_confirmation_flag = message_confirmation_flag ? false : true
    save
  end
end
