class Join < ApplicationRecord
  validates :token, uniqueness: true
  validates :token, presence: true
  after_initialize :set_token

  private

  def set_token
    self.token = self.token.presence || generate_token
  end

  def generate_token
    tmp_token = SecureRandom.urlsafe_base64(6)
    self.class.where(:token => tmp_token).blank? ? tmp_token : generate_token
  end
end
